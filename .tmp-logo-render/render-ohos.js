const sharp = require('d:/app/projects/whitenoise/.tmp-logo-render/node_modules/sharp');

// OHOS 应用图标：奶油底 + 巢形前景 合成一张
const combo = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="1024" height="1024">
  <rect width="64" height="64" fill="#F5F0E6"/>
  <g fill="none" stroke="#3D6B5E" stroke-width="4" stroke-linecap="round">
    <path d="M12 42 C12 26 24 16 32 12 C40 16 52 26 52 42" opacity="0.28"/>
    <path d="M18 42 C18 29 27 21 32 18 C37 21 46 29 46 42" opacity="0.5"/>
    <path d="M24 42 C24 33 29 27 32 25 C35 27 40 33 40 42" opacity="0.85"/>
  </g>
  <circle cx="32" cy="44" r="3" fill="#3D6B5E"/>
  <path d="M30.5 25 A 1.5 1.5 0 0 0 33.5 25" fill="none" stroke="#A8B89A" stroke-width="2" stroke-linecap="round"/>
</svg>`;

async function main() {
  await sharp(Buffer.from(combo)).resize(1024, 1024).png().toFile('d:/app/projects/whitenoise/snapp/ohos/AppScope/resources/base/media/app_icon.png');
  await sharp(Buffer.from(combo)).resize(1024, 1024).png().toFile('d:/app/projects/whitenoise/snapp/ohos/entry/src/main/resources/base/media/icon.png');
  console.log('done');
}
main();