// Inspect discover page DOM: grid columns, tab bar, sections
const list = await (await fetch('http://localhost:9222/json')).json();
const page = list.find((t) => t.type === 'page');
if (!page) { console.error('no page'); process.exit(1); }
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
let id = 0; const pending = new Map();
ws.onmessage = (ev) => { const m = JSON.parse(ev.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
const send = (method, params = {}) => new Promise((res) => { const mid = ++id; pending.set(mid, res); ws.send(JSON.stringify({ id: mid, method, params })); });
const evalJs = async (expr) => {
  const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true });
  if (r.result?.exceptionDetails) return 'EXC: ' + (r.result.exceptionDetails.exception?.description ?? '');
  return r.result?.result?.value;
};
await send('Page.enable');
await send('Page.navigate', { url: 'http://localhost:5174/#/pages/discover/discover' });
await new Promise((r) => setTimeout(r, 3000));

console.log('hash:', await evalJs('location.hash'));
console.log('tabbar present:', await evalJs(`!!document.querySelector('uni-tabbar') || !!document.querySelector('.tabbar, .tab-bar, .custom-tabbar')`));
console.log('scene-grid cards:', await evalJs(`(() => {
  const cards = Array.from(document.querySelectorAll('.scene-grid .scene-card'));
  if (!cards.length) return 'none';
  const rects = cards.map(c => { const r = c.getBoundingClientRect(); return Math.round(r.x) + 'x' + Math.round(r.width); });
  return cards.length + ' cards | ' + rects.join(' | ');
})()`));
console.log('sections:', await evalJs(`Array.from(document.querySelectorAll('.section-title')).map(el => el.textContent.trim()).join(' | ')`));
console.log('header:', await evalJs(`(() => {
  const t = document.querySelector('.header-text');
  return t ? t.textContent.replace(/\\s+/g,' ').trim() : 'none';
})()`));
console.log('app-bg sample:', await evalJs(`getComputedStyle(document.querySelector('.scene-card') || document.body).borderRadius`));
ws.close();
process.exit(0);
