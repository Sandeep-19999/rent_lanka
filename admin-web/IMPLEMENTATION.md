# Platform administration implementation

## Changed and added files

- `admin-web/README.md`
- `admin-web/src/App.jsx`
- `admin-web/src/components/common/Feedback.jsx`
- `admin-web/src/components/layout/AdminLayout.jsx`
- `admin-web/src/components/layout/Header.jsx`
- `admin-web/src/components/layout/Sidebar.jsx`
- `admin-web/src/pages/WithdrawalsPage.jsx`
- `admin-web/src/services/firebase.js`
- `admin-web/src/services/withdrawalPolicy.js`
- `admin-web/src/services/withdrawalService.js`
- `admin-web/src/styles/global.css`
- `admin-web/src/utils/authorization.js`
- `admin-web/src/utils/withdrawals.js`
- `admin-web/tests/withdrawals.test.js`
- `firebase/withdrawals.rules.test.cjs`
- `admin-web/src/components/common/PlatformRecords.jsx`
- `admin-web/src/components/common/StoredPhoto.jsx`
- `admin-web/src/hooks/useCollection.js`
- `admin-web/src/pages/EquipmentDetailsPage.jsx`
- `admin-web/src/pages/EquipmentPage.jsx`
- `admin-web/src/pages/UserDetailsPage.jsx`
- `admin-web/src/pages/UsersPage.jsx`
- `admin-web/src/pages/WithdrawalDetailsPage.jsx`
- `admin-web/src/utils/photoState.js`
- `admin-web/src/utils/platform.js`
- `admin-web/tests/photos.test.js`
- `admin-web/tests/platform.test.js`
- `firebase/ADMIN_REVIEW.md`
- `firebase/firebase.admin-review.json`
- `firebase/firestore.admin-review.rules`

- `admin-web/IMPLEMENTATION.md` (this inventory)

The pre-existing deletion of `.env.example` and modification of `package-lock.json` were preserved. No Flutter source changes.

## Validation

Local Node unit/render suite and Vite production build passed. The unit suite includes original payment/refund checks plus rejection, exact admin roles, missing-data normalization, secret omission and photo rendering/state checks. Firestore emulator and interactive browser smoke checks were not run (Firebase CLI and configured browser tooling unavailable). See `../firebase/ADMIN_REVIEW.md` for isolated emulator instructions and the backend access-control limitations.

## Run

From `admin-web`, use Node 22.12+, existing public Firebase Web configuration in ignored `.env.local`, and `npm run dev`. Run `npm test` and `npm run build` for local verification. Rejection defaults off and requires reviewed rules before setting `VITE_ENABLE_ADMIN_WITHDRAWAL_REJECTIONS=true`. Approval uses the existing separate flag and updates status/audit only, with no payout integration.
