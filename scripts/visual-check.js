const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const baseUrl = process.env.EMSILE_URL || 'http://127.0.0.1:8090';
const outputDir = path.join(__dirname, '..', 'docs', 'screenshots');
const navigationBarY = 806;

async function tap(page, x, y, wait = 700) {
  await page.touchscreen.tap(x, y);
  await page.waitForTimeout(wait);
}

async function main() {
  fs.mkdirSync(outputDir, { recursive: true });
  for (const file of fs.readdirSync(outputDir)) {
    if (file.endsWith('-mobile.png')) {
      fs.unlinkSync(path.join(outputDir, file));
    }
  }

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });

  const problems = [];
  page.on('console', (message) => {
    if (message.type() === 'error') {
      problems.push(`console: ${message.text()}`);
    }
  });
  page.on('pageerror', (error) => {
    problems.push(`pageerror: ${error.message}`);
  });

  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);
  await page.screenshot({
    path: path.join(outputDir, '01-home-mobile.png'),
    fullPage: true,
  });

  // 2. Fiil-i Mâzi ders detayı
  await tap(page, 117, navigationBarY);
  await tap(page, 190, 240);
  await tap(page, 190, 275);
  await page.screenshot({
    path: path.join(outputDir, '02-lesson-mobile.png'),
    fullPage: true,
  });
  await tap(page, 28, 28);
  await tap(page, 28, 28);

  // 3. Çekim tablosu
  await tap(page, 195, navigationBarY);
  await tap(page, 190, 120);
  await page.screenshot({
    path: path.join(outputDir, '03-conjugation-mobile.png'),
    fullPage: true,
  });

  // 4. Zamir tablosu
  await tap(page, 28, 28);
  await tap(page, 190, 230);
  await page.screenshot({
    path: path.join(outputDir, '04-pronouns-mobile.png'),
    fullPage: true,
  });
  await tap(page, 28, 28);

  // 5. Gerçek eşleştirme turu
  await tap(page, 275, navigationBarY);
  await tap(page, 190, 130);
  await tap(page, 195, 465);
  await page.screenshot({
    path: path.join(outputDir, '05-matching-mobile.png'),
    fullPage: true,
  });
  await tap(page, 35, 32);
  await tap(page, 35, 32);

  // 6. Gerçek tablo doldurma turu
  await tap(page, 190, 360);
  await tap(page, 195, 277);
  await page.screenshot({
    path: path.join(outputDir, '06-table-fill-mobile.png'),
    fullPage: true,
  });

  await browser.close();

  if (problems.length > 0) {
    console.error(problems.join('\n'));
    process.exit(1);
  }

  console.log(`Visual check passed: ${outputDir}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
