"""Local preview with the same clean-route fallback as GitHub Pages."""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='build/web', **kwargs)

    def send_error(self, code, message=None, explain=None):
        if code == 404 and '.' not in self.path.split('?')[0].split('/')[-1]:
            data = Path('build/web/index.html').read_bytes()
            self.send_response(404)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        else:
            super().send_error(code, message, explain)

ThreadingHTTPServer(('127.0.0.1', 7358), Handler).serve_forever()
