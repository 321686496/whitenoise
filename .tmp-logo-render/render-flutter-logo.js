const sharp = require('d:/app/projects/whitenoise/.tmp-logo-render/node_modules/sharp');
sharp('d:/app/projects/whitenoise/prototype/src/static/logo-v13.svg')
  .flatten({ background: '#F5F0E6' })
  .resize(512, 512)
  .png()
  .toFile('d:/app/projects/whitenoise/snapp/assets/brand/logo.jpg')
  .then(() => console.log('done'));