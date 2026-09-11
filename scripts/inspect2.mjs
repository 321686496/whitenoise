// Check computed styles of scene-grid and scene-card
const list = await (await fetch('http://localhost:9222/json')).json();
const page = list.find((t) => t.type === 'page');
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
console.log(await evalJs(`(() => {
  const grid = document.querySelector('.scene-grid');
  const card = document.querySelector('.scene-grid .scene-card');
  if (!grid || !card) return 'missing';
  const gs = getComputedStyle(grid), cs = getComputedStyle(card);
  const gr = grid.getBoundingClientRect();
  return JSON.stringify({
    gridW: Math.round(gr.width),
    gridDisplay: gs.display, gridFlexWrap: gs.flexWrap, gridGap: gs.gap, gridBoxSizing: gs.boxSizing,
    cardW: cs.width, cardBoxSizing: cs.boxSizing, cardFlex: cs.flex, cardFlexBasis: cs.flexBasis,
    containerW: Math.round(document.querySelector('.page-container').getBoundingClientRect().width),
  }, null, 1);
})()`));
ws.close();
process.exit(0);
