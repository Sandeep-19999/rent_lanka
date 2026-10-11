import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';

// Supply a temporary Playwright installation; no browser/test package is shipped.
const { chromium } = await import(process.env.RENT_LANKA_PLAYWRIGHT_MODULE || 'playwright');
const base = process.env.RENT_LANKA_QA_URL || 'http://127.0.0.1:5173';
const output = process.env.RENT_LANKA_QA_OUTPUT || '/private/tmp/rent-lanka-browser-results';
await mkdir(output, { recursive: true });
const browser = await chromium.launch({ headless: true,
  executablePath: process.env.RENT_LANKA_CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' });
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, acceptDownloads: true });
const page = await context.newPage();
page.setDefaultTimeout(15000);
const failures = [];
const warnings = [];
page.on('pageerror', (error) => failures.push(error.message));
page.on('console', (message) => {
  if (message.type() === 'error' && !/400 \(Bad Request\)/.test(message.text())) failures.push(message.text());
  if (message.type() === 'warning') warnings.push(message.text());
});

async function hasNoPageOverflow(label) {
  const sizes = await page.evaluate(() => ({ viewport: innerWidth, page: document.documentElement.scrollWidth }));
  assert.ok(sizes.page <= sizes.viewport + 1, `${label}: page width ${sizes.page} exceeds ${sizes.viewport}`);
}
async function resetFilters() {
  await page.getByRole('button', { name: 'Reset filters' }).click();
  await page.waitForFunction(() => document.querySelector('input[type="search"]').value === ''
    && document.querySelector('select[aria-label="Payment status"]').value === ''
    && document.querySelectorAll('tbody tr').length === 10, null, { timeout: 15000 });
}
const harness = (pathname = '/dashboard', role = 'admin') => `${base}/tests/ui-harness.html?page=${encodeURIComponent(pathname)}&role=${role}`;

try {
  await page.goto(`${base}/login`);
  await page.getByRole('heading', { name: 'Welcome back' }).waitFor();
  assert.equal(await page.locator('#password').getAttribute('type'), 'password');
  await page.getByRole('button', { name: 'Show password' }).click();
  assert.equal(await page.locator('#password').getAttribute('type'), 'text');
  await page.getByRole('button', { name: 'Hide password' }).click();
  await hasNoPageOverflow('Desktop login');
  await page.screenshot({ path: path.join(output, 'login-desktop.png'), fullPage: true });

  // Verify the SDK/form error path without sending credentials to production.
  await page.route(/identitytoolkit\.googleapis\.com\/.*accounts:signInWithPassword/, (route) => {
    const headers = { 'access-control-allow-origin': '*', 'access-control-allow-methods': 'POST, OPTIONS',
      'access-control-allow-headers': route.request().headers()['access-control-request-headers'] || '*' };
    return route.fulfill(route.request().method() === 'OPTIONS' ? { status: 204, headers } : {
      status: 400, headers, contentType: 'application/json', body: JSON.stringify({ error: { code: 400, message: 'INVALID_LOGIN_CREDENTIALS' } }),
    });
  });
  await page.getByLabel('Email address').fill('test@example.invalid');
  await page.getByLabel('Password', { exact: true }).fill('invalid-test-password');
  await page.getByRole('button', { name: 'Sign in to workspace' }).click();
  await page.getByRole('alert').filter({ hasText: 'The email or password is incorrect.' }).waitFor();
  await page.unroute(/identitytoolkit\.googleapis\.com\/.*accounts:signInWithPassword/);

  await page.goto(`${base}/payments/test-id`);
  await page.waitForURL('**/login');
  await page.reload();
  await page.getByRole('heading', { name: 'Welcome back' }).waitFor();
  await page.setViewportSize({ width: 390, height: 844 });
  await hasNoPageOverflow('Mobile login');
  await page.screenshot({ path: path.join(output, 'login-mobile.png'), fullPage: true });

  if (process.env.RENT_LANKA_QA_PRODUCTION !== '1') {
  for (const role of ['player', 'provider']) {
    await page.goto(harness('/dashboard', role));
    await page.getByRole('heading', { name: 'Welcome back' }).waitFor();
    assert.ok(await page.getByRole('alert').filter({ hasText: 'Access denied' }).isVisible());
    assert.equal(await page.getByRole('heading', { name: 'Payment overview' }).count(), 0);
  }

  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.goto(harness());
  await page.getByRole('heading', { name: 'Payment overview' }).waitFor();
  assert.equal(await page.locator('article').filter({ hasText: 'Total Payment Records' }).locator('.stat-value').innerText(), '29');
  assert.match(await page.locator('article').filter({ hasText: 'Total Payment Volume' }).locator('.stat-value').innerText(), /567,000/);
  assert.match(await page.locator('article').filter({ hasText: 'Paid Payment Volume' }).locator('.stat-value').innerText(), /441,000/);
  assert.match(await page.locator('article').filter({ hasText: 'Refunded Amount' }).locator('.stat-value').innerText(), /1,500/);
  for (const label of ['Weekly', 'Monthly', 'Daily']) await page.getByRole('button', { name: label, exact: true }).click();
  assert.equal(await page.locator('.recharts-surface').count(), 3);
  await hasNoPageOverflow('Desktop dashboard');
  await page.screenshot({ path: path.join(output, 'dashboard-fixture-desktop.png'), fullPage: true });

  await page.getByRole('button', { name: 'Collapse sidebar' }).click();
  assert.ok(await page.locator('.app-shell').evaluate((element) => element.classList.contains('sidebar-is-collapsed')));
  await page.getByRole('button', { name: 'Expand sidebar' }).click();
  await page.getByRole('link', { name: 'Payments', exact: true }).click();
  await page.getByRole('heading', { name: 'Payments', exact: true }).waitFor();
  await page.waitForFunction((count) => document.querySelectorAll('tbody tr').length === count, 10, { timeout: 15000 });
  await page.getByRole('button', { name: 'Next page', exact: true }).click();
  assert.match(await page.locator('.pagination-info').innerText(), /11–20/);
  console.log('Checking search and combined filters');
  await page.getByRole('searchbox', { name: 'Search payments' }).fill('Test Customer Alpha');
  await page.waitForFunction((count) => document.querySelectorAll('tbody tr').length === count, 1, { timeout: 15000 });
  await resetFilters();
  await page.getByLabel('Payment status', { exact: true }).selectOption('pay_on_pickup');
  await page.waitForFunction((count) => document.querySelectorAll('tbody tr').length === count, 6, { timeout: 15000 });
  await page.getByLabel('Payment method', { exact: true }).selectOption('cash');
  const downloadEvent = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Export CSV' }).click();
  const download = await downloadEvent;
  await download.saveAs(path.join(output, 'filtered-payments.csv'));
  const { readFile } = await import('node:fs/promises');
  const csv = await readFile(path.join(output, 'filtered-payments.csv'), 'utf8');
  assert.equal(csv.trim().split('\r\n').length, 7);
  assert.ok(csv.includes('pay_on_pickup') && !csv.includes('"paid"'));
  await resetFilters();
  await page.getByLabel('Sort records').selectOption('amount_desc');
  await page.waitForFunction(() => document.querySelector('tbody tr')?.innerText.includes('40,500'), null, { timeout: 15000 });
  await resetFilters();
  await page.getByLabel('From date (Asia/Colombo)').fill('2099-01-01');
  await page.getByRole('heading', { name: 'No matching records' }).waitFor();
  await page.getByRole('button', { name: 'Clear filters' }).click();

  console.log('Checking refund views');
  await page.getByRole('link', { name: 'Refunds', exact: true }).click();
  await page.getByRole('heading', { name: 'Refunds', exact: true }).waitFor();
  await page.waitForFunction((count) => document.querySelectorAll('tbody tr').length === count, 1, { timeout: 15000 });
  assert.ok(await page.getByText('Refund recording requires reviewed security rules.').isVisible());
  await page.getByRole('button', { name: /Awaiting review/ }).click();
  await page.waitForFunction((count) => document.querySelectorAll('tbody tr').length === count, 1, { timeout: 15000 });

  console.log('Checking withdrawal approval gate and confirmation');
  await page.goto(harness('/withdrawals'));
  await page.getByRole('heading', { name: 'Withdrawals', exact: true }).waitFor();
  assert.equal(await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).isDisabled(), true);
  await page.goto(`${harness('/withdrawals')}&approval=enabled`);
  const pendingRequest = page.locator('tbody tr').filter({ has: page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }) });
  assert.equal(await pendingRequest.locator('.status-badge').innerText(), 'Pending');
  await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).click();
  await page.getByRole('heading', { name: 'Approve provider withdrawal?' }).waitFor();
  assert.equal(await pendingRequest.locator('.status-badge').innerText(), 'Pending');
  await page.screenshot({ path: path.join(output, 'approval-fixture-desktop.png'), fullPage: true });
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  assert.equal(await page.locator('.confirm-dialog').count(), 0);
  assert.equal(await pendingRequest.locator('.status-badge').innerText(), 'Pending');
  await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).click();
  await page.getByLabel('Approval note (optional)').fill('Reviewed fixture request.');
  await page.getByRole('button', { name: 'Approve withdrawal', exact: true }).click();
  await page.getByText('Withdrawal approved. Bank payout is still outstanding.').waitFor();
  assert.equal(await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).count(), 0);
  assert.equal(await page.locator('tbody tr').filter({ hasText: 'Awaiting payout' }).count(), 2);
  assert.ok(await page.getByText('Reviewed fixture request.', { exact: true }).isVisible());
  await hasNoPageOverflow('Desktop withdrawals');
  await page.screenshot({ path: path.join(output, 'withdrawals-fixture-desktop.png'), fullPage: true });
  await page.goto(`${harness('/withdrawals')}&approval=enabled&approval_failure=1`);
  await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).click();
  await page.getByRole('button', { name: 'Approve withdrawal', exact: true }).click();
  await page.locator('.confirm-dialog').getByRole('alert').filter({ hasText: 'Test approval was denied.' }).waitFor();
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();

  console.log('Checking responsive navigation');
  for (const width of [768, 390]) {
    await page.setViewportSize({ width, height: 1000 });
    await page.goto(harness());
    await page.getByRole('heading', { name: 'Payment overview' }).waitFor();
    await hasNoPageOverflow(`${width}px dashboard`);
    await page.getByRole('button', { name: 'Open navigation' }).click();
    assert.ok(await page.locator('dialog.navigation-dialog').isVisible());
    await page.locator('dialog.navigation-dialog').getByRole('link', { name: 'Payments', exact: true }).click();
    await page.getByRole('heading', { name: 'Payments', exact: true }).waitFor();
    assert.equal(await page.locator('dialog.navigation-dialog').isVisible(), false);
    await hasNoPageOverflow(`${width}px payments`);
    assert.ok(await page.locator('.table-scroll').evaluate((element) => element.scrollWidth > element.clientWidth));
    await page.getByRole('button', { name: 'Open navigation' }).click();
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('dialog.navigation-dialog').isVisible(), false);
  }
  await page.screenshot({ path: path.join(output, 'payments-fixture-mobile.png'), fullPage: true });
  await page.goto(`${harness('/withdrawals')}&approval=enabled`);
  await page.getByRole('heading', { name: 'Withdrawals', exact: true }).waitFor();
  await hasNoPageOverflow('Mobile withdrawals');
  await page.getByRole('button', { name: 'Approve withdrawal test-withdrawal-1', exact: true }).click();
  await page.getByRole('heading', { name: 'Approve provider withdrawal?' }).waitFor();
  await page.screenshot({ path: path.join(output, 'approval-fixture-mobile.png'), fullPage: true });
  await page.keyboard.press('Escape');
  await page.locator('.confirm-dialog').waitFor({ state: 'detached' });
  }
  assert.deepEqual(failures, [], `Browser errors: ${JSON.stringify(failures)}`);
  console.log(JSON.stringify({ result: 'passed', browserErrors: failures, browserWarnings: warnings, screenshots: output,
    scope: process.env.RENT_LANKA_QA_PRODUCTION === '1'
      ? 'Production bundle: actual signed-out login/router and mocked login error. No live admin login or writes.'
      : 'Actual signed-out login/router; mocked login error; isolated roles, ledger, withdrawal approval and responsive UI fixtures. No live admin login or financial writes.' }, null, 2));
} catch (error) {
  console.error(JSON.stringify({ url: page.url(), browserErrors: failures,
    visibleText: (await page.locator('body').innerText()).slice(0, 5000) }, null, 2));
  await page.screenshot({ path: path.join(output, 'failure.png'), fullPage: true });
  throw error;
} finally { await context.close(); await browser.close(); }
