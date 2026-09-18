const sharp = require('d:/app/projects/whitenoise/.tmp-logo-render/node_modules/sharp');

// 前景层：透明背景，仅巢形图形（去掉原 Svg 里的奶油底 rect）
const fgSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="1024" height="1024">
  <g fill="none" stroke="#3D6B5E" stroke-width="4" stroke-linecap="round">
    <path d="M12 42 C12 26 24 16 32 12 C40 16 52 26 52 42" opacity="0.28"/>
    <path d="M18 42 C18 29 27 21 32 18 C37 21 46 29 46 42" opacity="0.5"/>
    <path d="M24 42 C24 33 29 27 32 25 C35 27 40 33 40 42" opacity="0.85"/>
  </g>
  <circle cx="32" cy="44" r="3" fill="#3D6B5E"/>
  <path d="M30.5 25 A 1.5 1.5 0 0 0 33.5 25" fill="none" stroke="#A8B89A" stroke-width="2" stroke-linecap="round"/>
</svg>`;

// 背景层：纯色奶油底（与现有 logo 底色一致）
const bgSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="1024" height="1024">
  <rect width="64" height="64" fill="#F5F0E6"/>
</svg>`;

async function main() {
  await sharp(Buffer.from(fgSvg)).png().toFile('d:/app/projects/whitenoise/prototype/src/static/logo-foreground.png');
  await sharp(Buffer.from(bgSvg)).png().toFile('d:/app/projects/whitenoise/prototype/src/static/logo-background.png');
  console.log('done');
}
main();