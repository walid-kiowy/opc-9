import http from 'node:http';
import { pathToFileURL } from 'node:url';
export function createServer(release = process.env.RELEASE_ID || 'local') {
  return http.createServer((req, res) => {
    const route = new URL(req.url, 'http://localhost').pathname;
    const ok = route === '/health' || route === '/version';
    res.writeHead(ok ? 200 : 404, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(ok ? {status:'ok', release} : {error:'not found'}));
  });
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const server = createServer();
  server.listen(Number(process.env.PORT || 3000), '127.0.0.1');
  for (const signal of ['SIGTERM','SIGINT']) process.on(signal, () => server.close());
}
