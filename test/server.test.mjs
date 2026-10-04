import test from 'node:test';
import assert from 'node:assert/strict';
import {createServer} from '../src/server.mjs';
async function withServer(fn) {
  const server = createServer('test-release');
  await new Promise(resolve => server.listen(0,'127.0.0.1',resolve));
  try { await fn(`http://127.0.0.1:${server.address().port}`); }
  finally { await new Promise(resolve => server.close(resolve)); }
}
test('health and version expose the deployed release', () => withServer(async base => {
  for (const path of ['/health','/version']) {
    const response = await fetch(base + path);
    assert.equal(response.status,200);
    assert.deepEqual(await response.json(),{status:'ok',release:'test-release'});
  }
}));
test('unknown route is rejected', () => withServer(async base => {
  const response = await fetch(base + '/missing');
  assert.equal(response.status,404);
}));
