"""Fake only the external authentication pipe; never registers a Polkit agent."""
import json
import sys

state = None
request_id = 0


def publish():
    print(json.dumps({"type": "state", **state}), flush=True)


for line in sys.stdin:
    event = json.loads(line)
    operation = event["op"]
    if operation == "start":
        request_id += 1
        state = {"id": request_id, "action": "org.freedesktop.policykit.exec",
                 "message": "Authenticate", "target": "root", "identities": ["kiasoh", "root"],
                 "selected": 0, "required": False, "prompt": "", "echo": False, "error": "",
                 "command": "pkexec /home/kiasoh/.config/quickshell/scripts/" + "folder/" * 40 + "qs-cpu-epp.sh balance_power"}
        publish()
        state.update(required=True, prompt="Password:")
        publish()
    elif operation == "retry":
        state.update(required=True, error="Authentication failed. Try again.", info="")
        publish()
    elif operation == "close":
        print(json.dumps({"type": "closed", "id": state["id"]}), flush=True)
        state = None
    else:
        assert event["id"] == state["id"], "Incorrect request ID"
        if operation == "respond":
            assert event["value"] == "test-response", "Incorrect response"
            state.update(required=False, info="Response received")
            publish()
        elif operation == "select":
            assert event["index"] == 1, "Incorrect identity"
            state.update(selected=1)
            publish()
        elif operation == "cancel":
            print(json.dumps({"type": "closed", "id": state["id"]}), flush=True)
            state = None
        else:
            raise AssertionError("Unexpected operation")
