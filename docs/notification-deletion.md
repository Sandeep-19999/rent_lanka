# Notification deletion

The existing screen reads `notifications` documents filtered by `userId`.
Both the trash icon and existing swipe gesture ask for confirmation, then call
`NotificationService.deleteNotification` with the document ID. A Firestore
transaction checks the stored owner before deleting. Cards, unread counts and
the existing empty state follow the same Firestore stream. Failed transactions
leave the document in place; offline deletion fails and can be retried online.
There is no local deletion list, new collection, or notification reseeding call.

## Deployed security rules

This repository contains Firebase app configuration but no Firestore security
rules source. The deployed rules were not available for inspection and have
not been changed or deployed. Client checks alone do not enforce security.

Within the existing `match /notifications/{notificationId}` block, ensure deletion
is allowed only when the authenticated user owns the existing document:

```firestore
allow delete: if request.auth != null
              && resource.data.userId == request.auth.uid;
```

No change is needed if the deployed rules already enforce this condition. The
transaction also needs existing owner-only read permission. Preserve existing
create/update permissions and notification delivery behavior. Review overlapping
`allow write` or recursive wildcard rules: an owner-only delete rule cannot
override another matching rule that grants broader access. Do not replace the
project's entire ruleset with this snippet.

See [Firebase's authentication and ownership rules documentation](https://firebase.google.com/docs/firestore/security/rules-conditions)
and [Firestore transactions](https://firebase.google.com/docs/firestore/manage-data/transactions).

## Live verification

Using test accounts and the Firebase emulator or development project:

1. Cancel deletion: the document and unread count remain unchanged.
2. Delete one unread notification: only its document disappears, unread count
   decreases, and the success snackbar appears.
3. Delete the final notification: the existing `No notifications yet` state appears.
4. Restart the app: deleted documents remain absent.
5. Deny deletion or disconnect: an error appears and the notification stays visible.
6. Try deleting another user's ID directly through the service and directly through
   the Firebase SDK: both must fail. Signed-out access must also fail.

Automated tests use controlled SDK doubles; they do not verify deployed rules
or make destructive changes to the live Firebase project.
