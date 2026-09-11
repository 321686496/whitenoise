// Minimal CDP full-page screenshot: node shot.mjs <url> <out.png>
const [url, out] = process.argv.slice(2);
const list = await (await fetch('http://localhost:9222/json')).json();
const page = list.find((t) => t.type === 'page');
if (!page) { console.error('no page'); process.exit(1); }
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
let id = 0; const pending = new Map();
ws.onmessage = (ev) => { const m = JSON.parse(ev.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
const send = (method, params = {}) => new Promise((res) => { const mid = ++id; pending.set(mid, res); ws.send(JSON.stringify({ id: mid, method, params })); });
await send('Page.enable');
await send('Page.navigate', { url });
await new Promise((r) => setTimeout(r, 3200));
const shot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true });
const fs = await import('node:fs');
fs.writeFileSync(out, Buffer.from(shot.result.data, 'base64'));
console.log('saved:', out);
ws.close();
process.exit(0);
