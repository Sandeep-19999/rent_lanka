# Manual withdrawal approval rules

`firestore.withdrawals.rules` is a complete, isolated, deployable **scoped**
ruleset for the deployed rules inspected on 11 October 2026. Deployment requires
the owner's approval. The owner approved deployment on 11 October 2026; the
release was deployed and its source verified against this file. It is separate
from the refund recommendation in
`admin-payment-rules.recommended.txt`.

- A provider creates only their own `pending` request, using their owned bank
  account snapshot and a server request timestamp. Approval fields cannot be
  supplied at creation.
- Only a trusted `users/{uid}.role == 'admin'` can update `pending` to `approved`.
  The amount/payee remain immutable. Admin UID, timestamps and optional note
  are validated. Repeat approval, reset, payout completion and deletion are
  denied. No listener or mobile action automatically approves.
- Authenticated mobile profile reads, signup, player/provider role selection,
  owner updates, favourites and player account deletion remain supported.
  Clients cannot create an admin role, replace another profile or demote/delete
  an admin profile. Provision admins through a trusted Console/Admin SDK flow.
- Bank account access requires ownership or admin read permission. Providers
  cannot change account ownership or read another provider's bank details.
- The old catch-all grant excludes `users`, `bank_accounts` and `withdrawals`,
  including their subcollections. Otherwise overlapping grants bypass the checks.

**Scope:** unrelated collections retain the existing open test grant expiring
1 March 2027. Existing booking/payment/exchange permissions are not redesigned
in this change. This does not secure the whole financial ledger or validate
aggregate available balances on the server. Refund writes remain disabled.
Approval preserves the amount already reserved by a pending request; it does
not transfer funds, debit earnings again, or mark payout completed.

## Local checks

Install existing `admin-web` dependencies first. Java 21+ and Firebase CLI are
required. From the repository root:

```sh
firebase emulators:exec --only firestore --project demo-rent-lanka-withdrawals --config firebase/firebase.withdrawals.json 'node --test firebase/withdrawals.rules.test.cjs'
```

Tests refuse any host other than `127.0.0.1:8180`, use a `demo-` project, and
never target `rent-lanka`. They cover pending submission, manual approval/audit,
private queries, tampering, duplicate/concurrent approval, self-promotion and
mobile profile/bank compatibility. See Firebase's
[rule testing documentation](https://firebase.google.com/docs/firestore/security/test-rules-emulator).

## After explicit deployment approval

Refresh the deployed rules if they have changed since inspection. Back up the
existing release before applying this scoped ruleset. From the repository root:

```sh
firebase deploy --only firestore:rules --project rent-lanka --config firebase/firebase.withdrawals.json
```

This changes only Firestore rules, without hosting, indexes, Auth creation, or
document writes. Once the deployed release matches the tested file, set
`VITE_ENABLE_ADMIN_WITHDRAWALS=true` in ignored `admin-web/.env.local` and restart
Vite or rebuild. Keep `VITE_ENABLE_ADMIN_REFUNDS=false`. Never enable approval
against the previous unrestricted rules.
