import http from 'node:http';
import os from 'node:os';
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const page = readFileSync(new URL('../public/index.html', import.meta.url));
export function createApp({ version = process.env.APP_VERSION || 'v1', title = process.env.APP_TITLE || 'Bashir’s Container Lab' } = {}) {
  const started = Date.now();
  let ready = true;
  const server = http.createServer((req, res) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('Content-Security-Policy', "default-src 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'");
    if (req.method !== 'GET' && req.method !== 'HEAD') {
      res.writeHead(405, { 'Content-Type': 'application/json', Allow: 'GET, HEAD' });
      return res.end(JSON.stringify({ error: 'Method not allowed' }));
    }
    const path = new URL(req.url, 'http://localhost').pathname;
    const sendJSON = (code, body) => { res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(req.method === 'HEAD' ? undefined : JSON.stringify(body)); };
    if (path === '/healthz') return sendJSON(200, { status: 'healthy' });
    if (path === '/readyz') return sendJSON(ready ? 200 : 503, { status: ready ? 'ready' : 'draining' });
    if (path === '/api/runtime') return sendJSON(200, {
      title, hostname: os.hostname(), podName: process.env.POD_NAME || os.hostname(),
      uptimeSeconds: Math.floor((Date.now() - started) / 1000), version,
      nodeVersion: process.version, uid: typeof process.getuid === 'function' ? process.getuid() : null
    });
    if (path === '/favicon.ico') { res.writeHead(204); return res.end(); }
    if (path === '/') { res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' }); return res.end(req.method === 'HEAD' ? undefined : page); }
    return sendJSON(404, { error: 'Not found' });
  });
  server.requestTimeout = 10000;
  server.headersTimeout = 10000;
  return { server, setReady: value => { ready = Boolean(value); } };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const { server, setReady } = createApp();
  const port = Number(process.env.PORT || 8080);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('PORT must be an integer from 1 to 65535');
  server.listen(port, '0.0.0.0', () => console.log(`Listening on ${port}`));
  let draining = false;
  const shutdown = () => {
    if (draining) return;
    draining = true;
    setReady(false);
    // Give endpoint removal a short propagation window before closing the listener.
    setTimeout(() => server.close(() => process.exit(0)), 5000);
    setTimeout(() => process.exit(1), 20000).unref();
  };
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}
