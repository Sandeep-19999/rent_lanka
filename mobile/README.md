# rent_lanka_mobile

A new Flutter project.

## Restoring a signed-in account

Startup waits for Firebase Authentication's first restored session event before
choosing a screen. Signed-in players return to Home, providers to their dashboard,
and accounts without a saved role to role selection. Signed-out users continue
to onboarding. Closing the app does not sign out the account.

Profile/network failures offer Retry rather than treating the account as signed
out. Authentication persistence is handled by Firebase; passwords are not copied
into app preferences. See [Firebase's Flutter auth documentation](https://firebase.google.com/docs/auth/flutter/manage-users).

After installing this change, restart the app, sign in once if necessary, fully
close it, and reopen. Check both player and provider accounts. Explicit logout
should still return to the signed-out flow on the next launch.

Run `flutter test --no-pub test/startup_session_test.dart` for startup routing,
delayed session restoration, retry and disposal checks.

## Getting Started

### Exchange editing and item reviews

Exchange Status shows **Edit Request** for the sender's pending request only.
The existing offer form opens with saved details, photo and message. Saving
updates that document without changing its recipient, requested item, creation
date or status. A live provider response locks the form; the save transaction
also rechecks ownership and pending status on retry, preventing an accept/save
race from editing an accepted request. Listed offers revalidate equipment
ownership/availability and use its current name/photo.

Rate & Review has a fixed item summary, with no completed-item picker. Open it
from a completed booking, review notification or equipment page. A booking ID
targets only that booking; an equipment entry targets only that equipment.
Missing/ineligible bookings never fall back to another item. The generic profile
entry shows **Your reviews**, with Edit/Delete on each submitted review and a
My Bookings link for new reviews. Equipment review cards show these actions only
for the signed-in owner's reviews. Edit opens the exact review booking, preserving
the saved rating/comment; delete requires confirmation and rechecks ownership in
a transaction. Rating aggregates update through the existing live listeners.

Run `flutter test --no-pub test/exchange_edit_test.dart test/exchange_edit_screen_test.dart test/equipment_reviews_test.dart`.
Tests use controlled SDK doubles, including a transaction retry when acceptance
races with editing. No live exchange/review document is mutated by these checks.
The exchange restrictions are implemented in the mobile UI/service; the existing
open test grant for `exchange_requests` has not been changed in this follow-up.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
