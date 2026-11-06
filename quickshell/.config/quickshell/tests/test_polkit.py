"""Exercise the listener with real Polkit identities and a fake PAM session."""
import contextlib
import importlib.util
import io
import json
import os
import shlex
import subprocess
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("qs_polkit", Path(__file__).resolve().parents[1] / "scripts/qs-polkit-agent.py")
agent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agent)


class Session:
    def __init__(self):
        self.handlers = {}
        self.responses = []

    def connect(self, name, callback):
        self.handlers[name] = callback

    def initiate(self):
        self.handlers["request"](self, "Password:", False)

    def response(self, value):
        self.responses.append(value)

    def cancel(self):
        self.handlers["completed"](self, False)


class Invocation:
    def return_value(self, value):
        self.success = True

    def return_dbus_error(self, name, message):
        self.error = name


class Authentication(unittest.TestCase):
    def setUp(self):
        self.output = io.StringIO()
        self.redirect = contextlib.redirect_stdout(self.output)
        self.redirect.__enter__()
        self.sessions = []

        def new_session(identity, cookie):
            session = Session()
            self.sessions.append(session)
            return session

        self.factory = patch.object(agent.PolkitAgent.Session, "new", new_session)
        self.factory.start()
        self.listener = agent.Listener()
        self.invocation = Invocation()
        self.command = "/a/very/long/path/" + "folder/" * 30 + "qs-cpu-epp.sh balance_power"
        details = {"command_line": self.command, "user.display": "root"}
        self.listener.begin("org.freedesktop.policykit.exec", "Shortened message", details,
                            "cookie", [agent.Polkit.UnixUser.new(0)], self.invocation)

    def tearDown(self):
        self.listener.cancel()
        self.factory.stop()
        self.redirect.__exit__(None, None, None)

    def events(self):
        return [json.loads(line) for line in self.output.getvalue().splitlines()]

    def test_full_command_and_secret_response(self):
        event = self.events()[-1]
        self.assertEqual(event["command"], self.command)
        self.assertTrue(event["required"])
        self.listener.handle({"id": event["id"], "op": "respond", "value": "test-secret"})
        self.assertEqual(self.sessions[0].responses, ["test-secret"])
        self.assertNotIn("test-secret", self.output.getvalue())
        self.sessions[0].handlers["completed"](self.sessions[0], True)
        self.assertEqual(self.events()[-1]["type"], "closed")
        self.assertTrue(self.invocation.success)

    def test_failure_retries_and_caller_cancellation_closes(self):
        self.sessions[0].handlers["completed"](self.sessions[0], False)
        self.assertTrue(self.events()[-1]["error"])
        self.assertTrue(self.events()[-1]["required"])
        self.assertEqual(len(self.sessions), 2)
        self.listener.cancel()
        self.assertEqual(self.invocation.error, "org.freedesktop.PolicyKit1.Error.Cancelled")
        self.assertEqual(self.events()[-1]["type"], "closed")

    def test_stale_or_invalid_requests_cannot_submit(self):
        self.listener.handle({"id": -1, "op": "respond", "value": "stale"})
        self.listener.handle({"id": self.events()[-1]["id"], "op": "select", "index": -1})
        self.assertEqual(self.sessions[0].responses, [])
        self.assertEqual(len(self.sessions), 1)

    def test_reads_full_caller_command_when_polkit_filters_details(self):
        command = ["/usr/bin/python3", "-c", "import time; time.sleep(3)", "long-" + "x" * 250]
        process = subprocess.Popen(command)
        try:
            actual = agent.command_for({"polkit.caller-pid": str(process.pid), "polkit.subject-pid": str(os.getpid())})
            self.assertEqual(actual, shlex.join(command))
            self.assertEqual(agent.command_for({"polkit.caller-pid": "../../etc/passwd"}), "")
        finally:
            process.terminate()
            process.wait()


if __name__ == "__main__":
    unittest.main()
