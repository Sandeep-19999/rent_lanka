# Rent Lanka payment administration

Separate React + Vite application for the existing `rent-lanka` Firebase project.
The Flutter application and its financial/lifecycle logic are unchanged.

## Run locally

Use Node.js 22.12+ (Node 24 LTS is also suitable).

```sh
cd admin-web
cp .env.example .env.local
npm install
npm run dev
```

Open the Local URL printed by Vite, normally `http://127.0.0.1:5173`.
An ignored `.env.local` may already be present from local setup. All six Web SDK
values in the example come from `mobile/lib/firebase_options.dart`; they identify
the existing Web App. Never put service-account JSON, Admin SDK keys or private
credentials in a Vite variable. Vite variables are included in browser bundles.

```sh
npm test
npm run build
npm run preview
```

Production output is `dist/`. Hosting must rewrite non-asset routes to
`index.html` for React Router. This work does not deploy the portal or rules.

## Provision an administrator

A development administrator was provisioned in `rent-lanka` on 11 October 2026:
`admin@rentlanka.example`. The login form also accepts the username `admin-sithuli`.
Its current password and UID are saved only in the
Git-ignored `.admin-credentials.local` file, outside the frontend configuration.
This `.example` address is a login identifier and does not receive email. Use an
email address you control when provisioning an account that needs email recovery.
The account was created through trusted Firebase CLI credentials, with a separate
`users/{uid}` document containing `role: "admin"`. No login/signup promotion code
was added. Existing users and deployed security rules were not modified.

To provision another administrator manually:

1. In Firebase Console, select **rent-lanka** and Authentication → Users.
2. Create a dedicated email/password account, or use an existing trusted account.
   Confirm Email/Password is enabled under Authentication → Sign-in method.
3. Copy its Authentication UID.
4. In Firestore, create/update `users/{uid}` through trusted Console access:
   `role: "admin"`, `uid: "<uid>"`, `name: "<admin name>"`, `email: "<email>"`.
5. Review deployed rules before allowing this role to read the financial records.
6. Sign in through `/login`.

Login never assigns roles and there is no signup or promotion screen. Exact
`role === "admin"` is required; player/provider/missing roles are denied. The
profile listener also removes protected routes when the role is revoked. Browser
session persistence survives refresh but ends when the browser session closes.
Use a dedicated administrator: the mobile login routes only player/provider roles.

## Routes and features

| Route | Purpose |
| --- | --- |
| `/login` | Firebase login, password visibility and administrator verification |
| `/dashboard` | All-time payment metrics, charts and recent transactions |
| `/payments` | Original charges; search, filters, sorting, paging and CSV |
| `/payments/:paymentId` | Payment, booking, equipment, account and audit information |
| `/transactions` | Full charge/refund history with filtered CSV export |
| `/refunds` | Recorded refunds and terminal rentals awaiting refund review |
| `/withdrawals` | Provider requests, masked bank information, approval review and audit |

Unknown routes redirect through the protected dashboard. Dates and date filters
use **Asia/Colombo**. Filters are retained in payment-page URLs. CSV exports include
all currently filtered rows, rather than only the visible page, and escape
spreadsheet formula prefixes. No sample records or fabricated statistics are used.

The interface uses a light white/red theme matching Rent Lanka: white cards,
soft grey backgrounds, dark readable text and `#ED1235` primary actions.
Green shows paid/approved records, amber shows awaiting payment/review, and purple
distinguishes refunds. Shared CSS tokens cover navigation, inputs, charts,
tooltips, tables, dialogs and loading states.

## Existing schema and reads

`payments` charge fields: `bookingId`, `bookingReference`, `playerId`, `providerId`,
`type: "charge"`, `method`, `amount`, `currency: "LKR"`, `status`, `transactionId`,
`cardLast4`, `bank`, `createdAt`.

Mobile refund fields are the same common fields with `type: "refund"` and
`status: "refunded"`; `cardLast4` and `bank` are omitted. Mobile refunds use
`payments/{bookingId}_refund`. Payment statuses are `paid`, `pay_on_pickup`,
`refunded`; methods are `card`, `online_banking`, `cash`. Unknown stored values
remain visible. Missing status/currency/amount are not guessed as paid/LKR/zero.
Missing `type` is treated as a charge, matching the mobile transaction mapper.
Numeric-string legacy amounts can be displayed but cannot authorize refund writes.

`rental_requests` provides the booking names, dates, equipment, price breakdown,
`status`, `paymentStatus`, `paymentMethod`, and transaction ID. `users` supplies
role and optional detail-page names/emails. `equipment` is read on the detail page.
The portal does not copy these into a second financial collection.

One shared payment listener serves all financial pages. Linked rental listeners
use groups of up to 30 document IDs rather than reading unrelated bookings.
Account/equipment reads are limited to the open detail page. The withdrawal
listener runs only on `/withdrawals`. All listeners unsubscribe on unmount/logout.
There is no `orderBy(createdAt)` query excluding old documents with missing dates.

The overview loads the complete payment collection so all-time totals are exact
for the accessible records. Table paging is client-side. For a large production
ledger, move summaries to trusted aggregation and use server-side paging; avoid
silently labelling a limited sample as an all-time total.

## Financial definitions

- **Total Payment Volume:** sum of original LKR charge amounts, including unpaid
  cash obligations. Excludes refund entries and unfamiliar record types.
- **Paid Payment Volume:** sum of original LKR charges with `status == "paid"`,
  before refunds. Original charges stay paid after a refund.
- **Refunded Amount:** sum of separate LKR refund entries marked `refunded`.
- **Pay-on-Pickup Bookings:** distinct booking IDs on charges marked `pay_on_pickup`.
- **Total Payment Records:** all payment documents, including refund/legacy entries.

Amounts missing a valid nonnegative number or explicit LKR currency are excluded
from LKR totals and flagged. Charts use the same definitions. No failed-attempt
metric exists because the mobile flow does not persist failures. Paid volume
includes deposits/fees and is not labelled platform revenue. Provider earnings
continue to depend on completed `rental_requests.totalAmount` minus applicable
withdrawals; this portal never recalculates or rewrites that balance.

## Refund controls and rule gate

**Refund writes are disabled by default** (`VITE_ENABLE_ADMIN_REFUNDS=false`). This
flag controls the UI/service workflow, not security: deployed Firestore rules
must enforce authorization independently.

The supported action is a **full system-side refund**, not a gateway transfer.
Only a paid card/online-banking charge with a matching **rejected or cancelled**
booking whose `paymentStatus` is still `paid` is eligible. Pending, accepted,
active and completed rentals are blocked. Existing mobile cancellation refunds
are shown, not duplicated. Existing rejected prepaid rentals may await review.

The service first checks all related payment documents for legacy refunds. Its
Firestore transaction rechecks the current administrator, charge, booking and
deterministic refund document before writing. It then:

1. Creates `payments/{bookingId}_refund` with the existing refund fields plus
   `originalPaymentId`, `refundReason`, `refundedBy`, `updatedAt`, `updatedBy`.
2. Updates only booking `paymentStatus: "refunded"`, `updatedAt`, `updatedBy`.

The charge is untouched. Server timestamps are used. Booking lifecycle status,
slots, equipment reservations, withdrawals, earnings and notifications are not
rewritten. The action requires a reason and confirmation. Duplicate clicks or
concurrent refunds of the same booking contend on the same refund document and
booking in a transaction. The write service repeats validation independent of UI.

The isolated [rule recommendation](../firebase/admin-payment-rules.recommended.txt)
is **not deployed and not a replacement ruleset**. No production Firebase
configuration is created for it. Merge its admin grants into the real rules and
AND its role guards into existing self-profile grants. Appending a restrictive
allow rule does not override a broader allow rule. Keep player/provider permissions
and test the merged rules before deployment. See Firebase's
[role-based rules](https://firebase.google.com/docs/firestore/solutions/role-based-access)
and [atomic transaction validation](https://firebase.google.com/docs/firestore/manage-data/transactions).

Before enabling the flag, inspect/reconcile any legacy alternate-ID refund
records and ensure every refund writer follows the deterministic ID pattern.
Rules cannot query the entire payment collection to detect legacy duplicates.
The preflight legacy check is an additional safeguard, not that security guarantee.
Then set the flag to `true` only after the merged rules are verified/deployed,
and restart Vite or rebuild. Never enable it simply to bypass permission errors.

## Provider withdrawal approval

The mobile submission creates `pending` without approval fields. Its success
message and history explain that it is awaiting admin approval. History shows
approved requests as awaiting bank payout, with approval date/note. The balance
calculation subtracts every withdrawal except `rejected` or `cancelled`.
Consequently, changing **pending → approved** keeps the existing reservation
without another debit or any rewrite of provider earnings.

On `/withdrawals`, a valid pending request has an **Approve** button. The
confirmation shows the amount, provider and masked bank snapshot, with an optional
note. The transaction rechecks the signed-in admin role, pending status, positive
numeric amount, complete bank snapshot and linked provider role before updating
only `status: "approved"`, `approvedAt`, `approvedBy`, `approvalNote`, `updatedAt`
and `updatedBy`. Dates use server timestamps. Already approved, completed,
rejected/cancelled and malformed requests cannot be approved again. Concurrent
approvals contend on the same withdrawal document. Approval dates/admin/notes
appear in the table and filtered CSV.

**Approval does not transfer money or mark a payout completed.** It does not
change the amount, bank information, requested date, payments, bookings, slots,
notifications or balances. It does not add a manual approval stage to card/online
payments, which the mobile flow already records as `paid`.

`VITE_ENABLE_ADMIN_WITHDRAWALS=false` disables both the button and write service
until secure rules are verified/deployed. The complete scoped
[withdrawal ruleset and deployment instructions](../firebase/README.md) protect
withdrawal creation/approval, bank ownership and admin role assignment. Local
emulator tests cover the actual rules. This flag is a workflow gate, not a
security boundary.

The live Firestore rules were inspected read-only on 11 October 2026. They contain
a catch-all test grant allowing **any client to read/write until 1 March 2027**.
The scoped ruleset excludes the protected collections from that grant; unrelated
mobile collections retain the existing grant. With explicit owner approval, it
was deployed on 11 October 2026 and its released source verified against the
tested file. The current local environment enables manual withdrawal approval;
the example flag stays false for installations that have not verified their
rules. Refund security requires its separate review; its flag remains disabled.

## Verification checklist

`npm test` exercises malformed legacy values, Colombo date boundaries, financial
totals, search/filter/sort, CSV formula safety, role checks, refund invariants,
duplicate rejection, withdrawal approval/audit invariants, and completed-rental protection. It uses isolated fixtures,
never production Firestore writes. These tests do not verify deployed rules.

`tests/browser-smoke.mjs` checks the actual signed-out login and route redirects,
intercepts invalid login credentials locally, and uses isolated context fixtures
for administrator/player/provider UI, totals, charts, filters, CSV, pagination,
withdrawal approval gating/confirmation/success/failure and responsive navigation.
The fixture HTML is a development-only entry, excluded
from `dist/`; the production application always reads Firestore.

For the optional browser check, install Playwright in a separate temporary folder
and run Vite in another terminal:

```sh
npm install --prefix /private/tmp/rent-lanka-browser-qa playwright
RENT_LANKA_PLAYWRIGHT_MODULE=/private/tmp/rent-lanka-browser-qa/node_modules/playwright/index.mjs node tests/browser-smoke.mjs
```

The script defaults to installed macOS Google Chrome and `http://127.0.0.1:5173`.
Set `RENT_LANKA_CHROME`, `RENT_LANKA_QA_URL` and `RENT_LANKA_QA_OUTPUT` to override
the browser executable, local URL or screenshot directory. To check the built
login/router, run `npm run preview -- --port 5174` in another terminal and use:

```sh
RENT_LANKA_QA_PRODUCTION=1 RENT_LANKA_QA_URL=http://127.0.0.1:5174 RENT_LANKA_PLAYWRIGHT_MODULE=/private/tmp/rent-lanka-browser-qa/node_modules/playwright/index.mjs node tests/browser-smoke.mjs
```

The dependency lockfile includes a scoped `@grpc/grpc-js` override to `^1.14.5`.
Firebase's Firestore package otherwise selects an older Node transport with
audit findings. The override stays within gRPC's major version and selects the
[maintainer's patched range](https://github.com/grpc/grpc-node/security/advisories/GHSA-m9gg-hp2v-232j).
This Node transport is not included in the browser build. Recheck the override
when updating Firebase, rather than applying an audit-driven Firebase downgrade.

With authorized test accounts and the project's verified rules:

1. Open `/login`; check password visibility, keyboard focus and mobile layout.
2. Log in with player/provider accounts; confirm dashboard access is denied.
3. Sign in as the trusted admin; refresh a protected URL; then revoke its role
   from trusted Console access and confirm protected pages close.
4. Create bookings from mobile. Confirm real records, names, amounts and methods.
5. Verify charge volume, cash obligations and refund totals remain separate.
6. Search by transaction/reference/customer; combine filters, sort, page and export.
   The CSV should contain all and only filtered records.
7. Open a detail page; check missing optional names, dates and linked documents.
8. With writes disabled, confirm refunds cannot be submitted.
9. After rule review, use emulator/test data for a rejected paid booking. Confirm
   one full refund, unchanged charge, updated booking payment status, unchanged
   lifecycle/reservations/earnings, and rejection of repeated/concurrent submissions.
10. Confirm completed/active rentals and mismatched records cannot be refunded.
11. In emulator/test data with reviewed rules, approve a pending withdrawal.
    Check its audit, unchanged amount/bank/requestedAt, unchanged provider balance,
    no completed status, repeated/concurrent rejection and non-admin denial.
    Check masked bank data, then logout and test a protected URL.
12. Check desktop, tablet and 390px mobile navigation, charts and horizontal tables.

## Limits

The default admin login/profile and deployed rule contents have been checked.
Live financial mutations and emulator validation of the recommended rules have
not been performed. Refund and withdrawal approval writes remain disabled until
the rule review described above. No rules or hosting deployment is performed.
Completed payout dates are not invented. Partial refunds, arbitrary payment
status editing, payout completion and real money movement are outside the
implemented workflow. See `VALIDATION.md` for local results.
