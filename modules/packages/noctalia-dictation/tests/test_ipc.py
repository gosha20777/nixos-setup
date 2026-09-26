import json
import socket
import sys
import time
from pathlib import Path

# Add src to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from ipc import IPCServer
from models import StateResponse


def test_ipc_server_command_and_broadcast(tmp_path, monkeypatch):
    test_sock_path = tmp_path / "test_dictation.sock"
    monkeypatch.setattr("ipc.get_socket_path", lambda: test_sock_path)

    current_state = StateResponse(state="idle")

    def handle_command(cmd: str) -> str:
        nonlocal current_state
        if cmd == "toggle":
            current_state = StateResponse(state="recording")
            return "ok: toggled"
        elif cmd == "stop":
            current_state = StateResponse(state="idle")
            return "ok: stopped"
        return "error: unknown"

    server = IPCServer(
        on_command=handle_command,
        get_current_state=lambda: current_state,
    )
    server.start()
    time.sleep(0.1)

    try:
        # 1. Test one-off command
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.connect(str(test_sock_path))
            client.sendall(b"toggle\n")
            resp = client.recv(1024).decode("utf-8").strip()
            assert resp == "ok: toggled"
            assert current_state.state == "recording"

        # 2. Test status command
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.connect(str(test_sock_path))
            client.sendall(b"status\n")
            resp = client.recv(1024).decode("utf-8").strip()
            data = json.loads(resp)
            assert data["state"] == "recording"

        # 3. Test subscriber stream
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sub_client:
            sub_client.settimeout(2.0)
            sub_client.connect(str(test_sock_path))
            sub_client.sendall(b"stream\n")

            # First message received is initial state
            initial_line = sub_client.recv(1024).decode("utf-8").strip()
            initial_data = json.loads(initial_line)
            assert initial_data["state"] == "recording"

            # Broadcast new state
            new_state = StateResponse(state="processing")
            server.broadcast(new_state)

            event_line = sub_client.recv(1024).decode("utf-8").strip()
            event_data = json.loads(event_line)
            assert event_data["state"] == "processing"

    finally:
        server.stop()
