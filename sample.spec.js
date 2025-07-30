import { test, expect } from '@playwright/test';
import { readFileSync, copyFileSync, unlinkSync } from 'fs';

const urls = readFileSync('sample_url.txt', 'utf-8').split('\n').filter(Boolean);
const originalTestCSV = 'market_share_history.csv';
const question = [
  '国別 E‑Series 市場シェア推移を棒グラフで表示して',
  '（各Quater全体販売台数を集計し、各国別E-Seriese販売台数を割り、市場シェアを算出する）。',
  'また、E-Seriese国別 UnitsSold を 2018Q1‑2025Q2 折れ線グラフで時系列可視化して。'
].join('');

test.describe.configure({ mode: 'parallel' });

for (const url of urls) {
  test(`DataRobot file upload and chat test for ${url}`, async ({ page }, testInfo) => {
    const randomId = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    const testCSV = `${originalTestCSV.replace(/\.[^/.]+$/, '')}_test_${randomId}.csv`;
    const testId = `Test-${randomId.substring(0, 8)}`;

    // Timing helpers
    let startTime = Date.now();
    let lastStepTime = startTime;
    let cumulativeTime = 0;
    function logStep(message) {
      const now = Date.now();
      const stepTime = now - lastStepTime;
      cumulativeTime = now - startTime;
      const timestamp = new Date(now).toISOString();
      console.log(`[${timestamp}] [${testId}] ${message} | Step: ${stepTime}ms | Total: ${cumulativeTime}ms`);
      lastStepTime = now;
    }
    function logError(message) {
      const now = Date.now();
      const stepTime = now - lastStepTime;
      cumulativeTime = now - startTime;
      const timestamp = new Date(now).toISOString();
      console.error(`[${timestamp}] [${testId}] ERROR: ${message} | Step: ${stepTime}ms | Total: ${cumulativeTime}ms`);
      lastStepTime = now;
    }

    copyFileSync(originalTestCSV, testCSV);
    logStep(`Starting test for URL: ${url.substring(url.length - 20)}...`);
    logStep(`Using test CSV file: ${testCSV}`);

    test.setTimeout(1200000);

    logStep(`Navigating to URL...`);
    await page.goto(url);

    // Upload data - single robust attempt for concurrent execution
    logStep(`Waiting for page to fully load...`);
    await page.waitForTimeout(3000);

    logStep(`Clicking Select data button...`);
    await page.getByRole('button', { name: 'Select data' }).click();

    logStep(`Clicking Add Data button...`);
    await page.getByRole('button', { name: 'Add Data' }).click();

    logStep(`Waiting for file input dialog...`);
    await page.waitForSelector('input[type="file"]', { state: 'attached' });

    logStep(`Uploading file: ${testCSV}`);
    await page.locator('input[type="file"]').setInputFiles(testCSV);

    logStep(`Clicking Save selections...`);
    await page.getByRole('button', { name: 'Save selections' }).click();

    logStep(`Waiting for file processing to complete...`);
    await expect(page.getByText('Processed').last()).toBeVisible({ timeout: 600000 });

    logStep(`File processed successfully! Waiting for UI to stabilize...`);
    await page.waitForTimeout(2000);

    logStep(`Navigating to Chats...`);
    await page.locator('div').filter({ hasText: /^Chats$/ }).first().click();

    logStep(`Waiting for chat page to load...`);
    await page.waitForURL('**/chats**', { timeout: 30000 });

    logStep(`Looking for chat input textbox...`);
    const chatInput = page.getByRole('textbox', { name: 'Ask another question about your datasets.' });
    await chatInput.waitFor({ state: 'visible', timeout: 30000 });

    logStep(`Entering question: "${question}"`);
    await chatInput.fill(question);
    await chatInput.press('Enter');

    logStep(`Waiting for DataRobot response...`);
    await page.waitForSelector('text=DataRobot', { timeout: 60000 });

    logStep(`Waiting for More insights tab to appear...`);
    await page.getByRole('tab', { name: 'More insights' }).waitFor({ state: 'visible', timeout: 600000 });

    logStep(`Clicking More insights tab...`);
    await page.getByRole('tab', { name: 'More insights' }).click();

    logStep(`Waiting for insights to load...`);
    await page.waitForTimeout(2000);

    logStep(`Test completed successfully!`);

    // clean up test CSV file
    logStep(`Cleaning up test CSV file: ${testCSV}`);
    try {
      await page.close();
      unlinkSync(testCSV);
      logStep(`Cleanup successful.`);
    } catch (error) {
      logError(`Error during cleanup: ${error.message}`);
    }
  });
}
