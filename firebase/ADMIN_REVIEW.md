# Local platform administration review (not deployed)

`firestore.admin-review.rules` and `firebase.admin-review.json` are a separate local candidate. The historically deployed approval-only file/config are unchanged. Never deploy this candidate as a complete production security solution: it deliberately retains the baseline unrelated-collection test grant so that mobile/payment permissions are not silently replaced.

## Exact withdrawal change

Add `manualRejection()` to the withdrawal update grant alongside `manualApproval()`. It permits only admin `pending -> rejected`, validates the provider and existing payee snapshot, keeps amount/payee/request date immutable, requires a nonempty reason of at most 500 characters, and requires the authenticated UID and request-time timestamps. Approval and rejection both refuse existing decision audit fields. No deletion, reset or completion grant is added.

New optional rejection fields: `rejectedAt`, `rejectedBy`, `rejectionReason`; existing `updatedAt`, `updatedBy` are reused. These fields are necessary because the existing mobile schema recognizes `rejected` but has no rejection audit fields. Existing mobile readers ignore unknown fields. Rejection releases the reservation through the existing balance calculation; no earnings/payment/bank documents are written.

## Local emulator verification

Firebase CLI and Java 21+ are required. Dependencies come from `admin-web/node_modules`. From the repository root in PowerShell:

```powershell
$env:RENT_LANKA_TEST_REJECTIONS = 'true'
firebase emulators:exec --only firestore --project demo-rent-lanka-withdrawals --config firebase/firebase.admin-review.json 'node --test firebase/withdrawals.rules.test.cjs'
Remove-Item Env:RENT_LANKA_TEST_REJECTIONS
```

The suite refuses any host except `127.0.0.1:8180` and uses only a `demo-` project. The additional rejection cases cover audit, reason, immutable fields, non-admin decisions, repeated/cross-decisions and concurrent approval/rejection. Existing approval/mobile compatibility cases still run. Without the environment flag the same suite continues to test the unchanged baseline rules.

## Collection access review still required

The checked-in baseline permits authenticated profile reads for mobile discovery/chat/booking, and retains a broad time-limited test grant for unrelated collections including `payments`, `rental_requests` and `equipment`. UI protection cannot fix those backend grants. This change does not claim that backend access to those collections is admin-only.

Before production use, refresh the deployed rules through the trusted rules-management process, and remove the broad catch-all for at least `payments`, `rental_requests` and `equipment`, including subcollections. Replace it with explicitly reviewed mobile-compatible ownership/participant/public-listing grants and exact admin `allow read: if admin()` grants. Do not blindly exclude collections without their mobile replacement rules: that would break booking, availability and payment behavior. Preserve the existing refund guards; do not add unrestricted admin ledger update/delete grants. The refund recommendation remains separate and its write gate remains unchanged.

The new admin collection queries need `allow read` (including list), not just `allow get`, for users/equipment/rental_requests. The baseline already allows them too broadly; in `admin-payment-rules.recommended.txt`, the equipment/users get-only admin snippets should be extended to read when merged, while retaining required mobile profile/listing access. Queries in this implementation use single providerId/playerId/equipmentId equality filters and no compound ordering.

Account suspension would require a trusted account-status field, server-side enforcement in Auth/app/rules, and protected audit records. Listing moderation would require a separate moderation state, audited transitions and visibility/booking enforcement in mobile and rules. Neither action is added as an availability/profile toggle.

No CLI was available on this workstation to run the Firestore emulator during implementation. The candidate rules must be emulator-tested and reviewed before enabling rejection. No deployment or production writes were performed.
