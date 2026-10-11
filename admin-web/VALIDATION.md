# Local validation

Validated on 11 October 2026, on `feature/admin-payment-dashboard`.

## Manual approval and mobile follow-up

- Mobile submits only `pending`; approval/audit fields are absent at creation.
  Submission and history explain awaiting admin approval versus awaiting payout.
  Approval date/note are displayed, and non-finite amounts are rejected.
- `flutter test --no-pub`: **129 passed**, including 5 new withdrawal request,
  legacy mapping and narrow-phone history tests. Analysis of the six changed
  withdrawal files/test reports **no issues**.
- `npm test`: **21 passed**; `npm run build`: **passed**.
- Browser smoke: **passed**, no errors/warnings. Opening the enabled withdrawal
  page, opening its modal, and cancelling leave the fixture request pending.
  Only explicit confirmation approves. Screenshots are in
  `/private/tmp/rent-lanka-manual-approval-results/`.
- `firebase/withdrawals.rules.test.cjs`: **8 passed** against the actual
  `firestore.withdrawals.rules` in the local demo Firestore emulator. Covered
  pending creation, provider/anonymous denial, server audit, immutable payee/
  amount, concurrency, private queries and mobile role/profile/bank operations.
- With explicit owner approval, the scoped ruleset was deployed to `rent-lanka`
  on 11 October 2026 (release updated at 10:12:39 UTC). The released source was
  read back and matches the tested file. The previous ruleset was backed up in
  `/private/tmp/rent-lanka-admin-setup/pre-withdrawal-deployment-rules.json`.
  Local manual approval is enabled; the example flag stays false. No live
  withdrawal was changed. Unrelated collections retain their existing test
  grant; refund writes remain disabled.
- Read-only live Chrome verification passed: actual admin sign-in and withdrawal
  listener, five enabled eligible approval buttons on the displayed page,
  opening/cancelling confirmation leaves the request pending, and anonymous
  withdrawal reads return 403. No browser errors or financial document writes.
  Screenshot: `/private/tmp/rent-lanka-manual-approval-results/withdrawals-live-read-only.png`.

The sections below record earlier validation stages.

## White/red theme and withdrawal approval follow-up

- The application now uses a light white/red theme across login, navigation,
  financial cards, charts, tooltips, tables, badges, dialogs and loading states.
  Screenshots of the login, dashboard and withdrawals were visually inspected.
- `npm test`: **21 passed, 0 failed**, including pending-to-approved withdrawal
  policy, immutable amount/bank/requestedAt, duplicate/stale requests, revoked
  administrator roles, missing provider, malformed legacy data and audit fields.
- `npm run build`: **passed** with no warnings.
- The browser checks passed with **no errors or warnings**. In addition to the
  existing ledger checks, isolated withdrawal fixtures exercise the disabled
  write gate, confirmation/cancellation, approval success and audit display,
  approval failure and responsive layouts. No live withdrawal was changed.
- Current screenshots are in `/private/tmp/rent-lanka-light-browser-results/`.
- Deployed rules were read through existing Firebase CLI credentials. They have
  a catch-all test rule permitting unauthenticated reads/writes until 1 March
  2027. No deployed rule was changed. The recommendation adds a restricted
  pending-to-approved grant, but the catch-all must be removed in a reviewed,
  mobile-compatible ruleset before that restriction can be effective.
- `VITE_ENABLE_ADMIN_WITHDRAWALS=false` and `VITE_ENABLE_ADMIN_REFUNDS=false`
  remain the default. These are UI/service gates, not security boundaries.
  Emulator verification and rule deployment were still required at this stage before enabling
  financial writes. The new approval records a review decision; it does not
  complete a bank payout, debit the provider balance again or edit payments.

## Administrator setup follow-up

After the user requested a default administrator, a dedicated Firebase
Authentication account (`admin@rentlanka.example`) and its new `users/{uid}`
admin profile were created using the project owner's existing Firebase CLI
credentials. Both records were read back and verified. The generated password
is stored in the Git-ignored `.admin-credentials.local` file with owner-only
permissions. It is not embedded in the frontend, environment example or docs.
No existing account, financial record or deployed rule was modified.
Email/password sign-in and reading the account's own admin profile with the
resulting Firebase user token both passed. Live financial collection reads and
refund writes were not exercised in this setup check.

The implementation checks below record the earlier validation run; account
setup is a separate follow-up, not a rules or hosting deployment.

| Check | Result |
| --- | --- |
| `npm install` | **Passed**, normal TLS verification, lockfile generated |
| npm dependency audit during installation | **0 vulnerabilities**, 197 packages audited |
| `npm test` | **15 passed, 0 failed** |
| `npm run build` | **Passed**, 2,232 modules; no chunk size/cycle warnings |
| Vite dev server and production preview | **Started successfully** on localhost |
| Headless Chrome development UI checks | **Passed**, no browser errors or warnings |
| Headless Chrome production login/router checks | **Passed**, no browser errors or warnings |
| Git whitespace check | **Passed** |
| Mobile changes | **None** |
| `.env.local`, `node_modules/`, `dist/` ignore rules | Verified; `.env.example` retained |
| Production bundle contains UI fixture records | **No**; fixture entry excluded |
| Live admin/non-admin login, Firestore reads and writes | Not performed; no test credentials or deployed rule access supplied |
| Rule deployment / hosting deployment / commits | **None** |

The registry connectivity problem reported on 10 October was resolved after the
network change. Installation completed without disabling TLS verification or
changing global npm configuration. A same-major gRPC override resolves the
transitive audit findings; Firebase remains on version 12.19.0. The installed
gRPC version is 1.14.6. npm reported unapproved optional/dependency install scripts;
no global script approval was added, and the build succeeded as installed.

## Browser coverage

`tests/browser-smoke.mjs` ran in installed Google Chrome through a temporary
Playwright installation outside the application dependencies. Fresh isolated
browser contexts were used; no production financial writes were made.

- Actual login: rendering, password show/hide, locally intercepted invalid-login
  response, friendly error display, signed-out protected URL redirect and refresh.
- Isolated UI context fixtures: player/provider access denial and admin layout;
  known financial totals, three charts and daily/weekly/monthly controls;
  sidebar collapse/expand; paging, search, combined status/method filters,
  amount sorting, date empty state/reset and filtered CSV download; recorded
  refund/review tabs and the disabled refund-write gate.
- Responsive checks at 1,440px, 768px and 390px: no horizontal page overflow;
  tablet/mobile drawer opens, closes after navigation and closes on Escape;
  financial tables scroll horizontally within their panels.
- Production `dist/`: actual login, locally intercepted invalid-login response,
  protected-route redirect/refresh and desktop/mobile login width checks. This
  verifies the split Firebase bundles initialize in the browser.

Screenshots were visually inspected. Development screenshots and the filtered
CSV are in `/private/tmp/rent-lanka-browser-results/`; production screenshots
are in `/private/tmp/rent-lanka-production-results/`. These temporary artifacts
are not part of the repository. See `README.md` to reproduce the browser checks.

## Remaining project-access checks

The UI fixtures do **not** validate live Firebase authorization or the deployed
Firestore rules. Use the authorized account/rules checklist in `README.md` for
real admin login, refresh/revocation/logout, live payment/detail/withdrawal reads,
and emulator or test-project refund transactions with the merged rules.

Leave `VITE_ENABLE_ADMIN_REFUNDS=false` until the actual deployed rules have been
reviewed, safely merged, and tested. The isolated rule recommendation has not
been emulator-tested against the project's deployed rules or deployed anywhere.
