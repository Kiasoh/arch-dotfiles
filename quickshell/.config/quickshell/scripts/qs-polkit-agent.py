#!/usr/bin/env python3
"""Polkit/PAM listener; JSON UI events out, responses in through private pipes."""
import json
import os
import pwd
import signal
import shlex
import sys
from pathlib import Path

import gi

gi.require_version("Polkit", "1.0")
gi.require_version("PolkitAgent", "1.0")
from gi.repository import Gio, GLib, GLibUnix, Polkit, PolkitAgent


def command_for(details):
    command = details.get("command_line") or details.get("program")
    if command:
        return command
    # Polkit strips command details, but supplies the requesting process PID.
    pid = details.get("polkit.caller-pid") or details.get("polkit.subject-pid") or ""
    if pid.isdecimal() and int(pid) > 0:
        try:
            args = Path(f"/proc/{pid}/cmdline").read_bytes().rstrip(b"\0").split(b"\0")
            return shlex.join(os.fsdecode(arg) for arg in args)
        except OSError:
            pass
    return ""


class Listener:
    def __init__(self):
        self.invocation = None
        self.session = None
        self.request_id = 0
        self.cancelled = False
        self.state = {}

    def publish(self):
        print(json.dumps({"type": "state", **self.state}), flush=True)

    def begin(self, action_id, message, details, cookie, identities, invocation):
        self.cancel()
        self.request_id += 1
        self.invocation = invocation
        self.cookie = cookie
        self.identities = identities
        self.cancelled = False
        names = []
        for identity in identities:
            try:
                user = pwd.getpwuid(identity.get_uid())
                names.append(user.pw_name)
            except (AttributeError, KeyError):
                names.append(identity.to_string())
        self.state = {"id": self.request_id, "action": action_id, "message": message,
                      "command": command_for(details),
                      "target": details.get("user.display") or "", "identities": names,
                      "selected": 0, "required": False, "prompt": "", "echo": False, "error": ""}
        if not identities:
            self.cancel()
            return
        self.start_session(0)

    def start_session(self, index):
        old = self.session
        self.session = None
        if old:
            old.cancel()
        self.state.update(selected=index, required=False, prompt="", echo=False)
        session = PolkitAgent.Session.new(self.identities[index], self.cookie)
        self.session = session
        session.connect("request", self.on_request)
        session.connect("show-error", self.on_error)
        session.connect("show-info", self.on_info)
        session.connect("completed", self.on_completed)
        self.publish()
        session.initiate()

    def on_request(self, session, prompt, echo):
        if session is self.session:
            self.state.update(required=True, prompt=prompt, echo=echo)
            self.publish()

    def on_error(self, session, message):
        if session is self.session:
            self.state["error"] = message
            self.publish()

    def on_info(self, session, message):
        if session is self.session:
            self.state["info"] = message
            self.publish()

    def on_completed(self, session, success):
        if session is not self.session:
            return
        self.session = None
        if success or self.cancelled:
            self.close()
        else:
            self.state["error"] = "Authentication failed. Try again."
            self.start_session(self.state["selected"])

    def handle(self, request):
        if not isinstance(request, dict) or not self.invocation or request.get("id") != self.request_id:
            return
        operation = request.get("op")
        if operation == "cancel":
            self.cancel()
        elif operation == "respond" and self.session and self.state["required"]:
            value = request.get("value")
            if isinstance(value, str):
                self.state.update(required=False, prompt="", echo=False, error="", info="")
                self.publish()
                self.session.response(value)
        elif operation == "select":
            index = request.get("index")
            if type(index) is int and 0 <= index < len(self.identities) and index != self.state["selected"]:
                self.state.update(error="", info="")
                self.start_session(index)

    def cancel(self):
        if self.invocation:
            self.cancelled = True
            if self.session:
                self.session.cancel()
            self.close()

    def close(self):
        if not self.invocation:
            return
        invocation, self.invocation = self.invocation, None
        self.session = None
        print(json.dumps({"type": "closed", "id": self.request_id}), flush=True)
        if self.cancelled:
            invocation.return_dbus_error("org.freedesktop.PolicyKit1.Error.Cancelled", "Authentication cancelled.")
        else:
            invocation.return_value(None)


def main():
    loop = GLib.MainLoop()
    listener = Listener()
    connection = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    owner = connection.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
                                 "GetNameOwner", GLib.Variant("(s)", ("org.freedesktop.PolicyKit1",)),
                                 GLib.VariantType.new("(s)"), Gio.DBusCallFlags.NONE, -1, None).unpack()[0]
    path = "/org/quickshell/PolkitAgent"
    interface = Gio.DBusNodeInfo.new_for_xml("""
    <node><interface name="org.freedesktop.PolicyKit1.AuthenticationAgent">
      <method name="BeginAuthentication">
        <arg type="s" direction="in"/><arg type="s" direction="in"/>
        <arg type="s" direction="in"/><arg type="a{ss}" direction="in"/>
        <arg type="s" direction="in"/><arg type="a(sa{sv})" direction="in"/>
      </method>
      <method name="CancelAuthentication"><arg type="s" direction="in"/></method>
    </interface></node>""").interfaces[0]

    def method_call(connection, sender, path, interface, method, parameters, invocation):
        if sender != owner:
            invocation.return_dbus_error("org.freedesktop.PolicyKit1.Error.NotAuthorized", "Only Polkit may request authentication.")
            return
        if method == "CancelAuthentication":
            if listener.invocation and parameters.unpack()[0] == listener.cookie:
                listener.cancel()
            invocation.return_value(None)
        else:
            action, message, icon, details, cookie, offered = parameters.unpack()
            identities = []
            for kind, values in offered:
                if kind == "unix-user" and "uid" in values:
                    identities.append(Polkit.UnixUser.new(values["uid"]))
                elif kind == "unix-group" and "gid" in values:
                    identities.append(Polkit.UnixGroup.new(values["gid"]))
            listener.begin(action, message, details, cookie, identities, invocation)

    object_id = connection.register_object(path, interface, method_call, None, None)
    authority = Polkit.Authority.get_sync(None)
    subject = Polkit.UnixSession.new_for_process_sync(os.getpid())
    authority.register_authentication_agent_sync(subject, os.environ.get("LANG", "C"), path, None)
    connection.signal_subscribe("org.freedesktop.DBus", "org.freedesktop.DBus", "NameOwnerChanged",
                                "/org/freedesktop/DBus", "org.freedesktop.PolicyKit1", Gio.DBusSignalFlags.NONE,
                                lambda *args: loop.quit())
    print(json.dumps({"type": "ready"}), flush=True)
    buffer = bytearray()
    os.set_blocking(sys.stdin.fileno(), False)

    def receive(source, condition):
        chunk = os.read(sys.stdin.fileno(), 65536)
        if not chunk:
            listener.cancel()
            loop.quit()
            return False
        buffer.extend(chunk)
        while b"\n" in buffer:
            line, _, remaining = buffer.partition(b"\n")
            buffer[:] = remaining
            try:
                listener.handle(json.loads(line))
            except (ValueError, UnicodeError):
                pass
        if len(buffer) > 65536:
            buffer.clear()
            listener.cancel()
        return True

    GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, receive)
    for signum in (signal.SIGTERM, signal.SIGINT):
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signum, lambda: (listener.cancel(), loop.quit(), False)[-1])
    try:
        loop.run()
    finally:
        listener.cancel()
        authority.unregister_authentication_agent_sync(subject, path, None)
        connection.unregister_object(object_id)


if __name__ == "__main__":
    try:
        main()
    except GLib.Error as error:
        print("Polkit agent could not start: " + error.message, file=sys.stderr)
        sys.exit(1)
