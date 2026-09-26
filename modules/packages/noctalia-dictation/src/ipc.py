import os
import socket
import sys
import threading
from pathlib import Path
from typing import Callable, List
from models import StateResponse


def get_socket_path() -> Path:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir:
        return Path(runtime_dir) / "noctalia-dictation.sock"
    return Path(f"/tmp/noctalia-dictation-{os.getuid()}.sock")


class IPCServer:
    def __init__(
        self,
        on_command: Callable[[str], str],
        get_current_state: Callable[[], StateResponse],
    ):
        self.on_command = on_command
        self.get_current_state = get_current_state
        self.socket_path = get_socket_path()
        self._server_sock: socket.socket | None = None
        self._running = False
        self._thread: threading.Thread | None = None
        self._subscribers: List[socket.socket] = []
        self._subscribers_lock = threading.Lock()

    def start(self) -> None:
        if self.socket_path.exists():
            try:
                self.socket_path.unlink()
            except Exception:
                pass

        self._server_sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self._server_sock.bind(str(self.socket_path))
        self._server_sock.listen(10)
        self._running = True

        self._thread = threading.Thread(target=self._listen_loop, daemon=True)
        self._thread.start()

    def broadcast(self, state: StateResponse) -> None:
        """Broadcast state as NDJSON to all active stream subscribers."""
        payload = (state.model_dump_json() + "\n").encode("utf-8")
        dead_conns = []
        with self._subscribers_lock:
            for conn in self._subscribers:
                try:
                    conn.sendall(payload)
                except Exception:
                    dead_conns.append(conn)

            for conn in dead_conns:
                if conn in self._subscribers:
                    self._subscribers.remove(conn)

    def _listen_loop(self) -> None:
        while self._running and self._server_sock:
            try:
                conn, _ = self._server_sock.accept()
                threading.Thread(target=self._handle_client, args=(conn,), daemon=True).start()
            except Exception:
                break

    def _handle_client(self, conn: socket.socket) -> None:
        try:
            data = conn.recv(1024).decode("utf-8").strip()
            if not data:
                conn.close()
                return

            if data == "stream":
                # Immediately send current state on connect
                initial_state = self.get_current_state()
                conn.sendall((initial_state.model_dump_json() + "\n").encode("utf-8"))
                with self._subscribers_lock:
                    self._subscribers.append(conn)
                # Keep socket open to receive streaming events
                return

            # Non-streaming command
            with conn:
                if data == "status":
                    response = self.get_current_state().model_dump_json()
                else:
                    response = self.on_command(data)
                conn.sendall(f"{response}\n".encode("utf-8"))
        except Exception as e:
            try:
                conn.sendall(f"error: {e}\n".encode("utf-8"))
                conn.close()
            except Exception:
                pass

    def stop(self) -> None:
        self._running = False
        with self._subscribers_lock:
            for conn in self._subscribers:
                try:
                    conn.close()
                except Exception:
                    pass
            self._subscribers.clear()

        if self._server_sock:
            try:
                self._server_sock.close()
            except Exception:
                pass
        if self.socket_path.exists():
            try:
                self.socket_path.unlink()
            except Exception:
                pass


def send_ipc_command(command: str) -> str:
    """Send one-off command to running daemon and return response."""
    socket_path = get_socket_path()
    if not socket_path.exists():
        raise ConnectionError("noctalia-dictation daemon is not running")

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(3.0)
        client.connect(str(socket_path))
        client.sendall(f"{command}\n".encode("utf-8"))
        response = client.recv(1024).decode("utf-8").strip()
        return response


def stream_ipc_events() -> None:
    """Stream NDJSON events from daemon to stdout indefinitely."""
    socket_path = get_socket_path()
    if not socket_path.exists():
        print('{"state":"idle","error":"daemon not running"}', flush=True)
        sys.exit(0)

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.connect(str(socket_path))
        client.sendall(b"stream\n")

        buffer = ""
        while True:
            chunk = client.recv(1024).decode("utf-8")
            if not chunk:
                break
            buffer += chunk
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                line = line.strip()
                if line:
                    print(line, flush=True)
