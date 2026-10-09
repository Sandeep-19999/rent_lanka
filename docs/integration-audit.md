# Rent Lanka integration audit

Branch: `integrate/booking-payment`. Local code changes only; no commits, pushes, merges, branch switches, remote data migration, or Firebase configuration changes.

## Scope and verification

Inspected the production module/navigation/service inventory (103 Dart files across the four features and shared entrypoints), active placeholder/demo markers, collection references, and existing tests. Traced the feature routes and the lifecycle/service boundaries changed below. This is a source-code and local test audit, not a completed two-account Firebase acceptance test.

- `flutter analyze`: zero errors; the original 4 warnings and 11 informational issues remain. Exit code 1 reflects those existing issues.
- `flutter test`: 50 tests passed. New tests cover reservations/manual blocks, state eligibility, review ownership, notification destinations, legacy notification references, and real transaction-record mapping. Existing role, navigation, chat-context, and booking/payment tests remain passing.
- Android debug build: `flutter build apk --debug` succeeded. APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`. Existing Gradle/Kotlin plugin compatibility warnings remain.
- Staged changes: none.

## Overall flow

Splash → onboarding/authentication → login/signup → saved-role routing or Role Selection.

Player: Home → Search/Category/Filter/Location → Equipment Details → Book Now → Rental Booking → Summary → Payment → Confirmation → My Bookings → Booking Details → contextual Message Provider; completed bookings → Rate & Review. Equipment Details → Exchange Request → Exchange Status → existing messaging.

Provider: Dashboard → Add Equipment / My Items / Requests → Request Details → accept/reject → Pickup & Return → handover → active → return → completed. Request Details → Message user → the same context chat as Player Booking Details. Dashboard bell → existing Notifications. Provider and Player profile screens and their separate navigation remain intact.

## Feature status

| Area | Local result |
|---|---|
| Role/profile/bottom tabs | Existing routing preserved; not rewritten. |
| Player discovery/booking | Existing flow preserved; transaction serializes new reservations on the equipment document. |
| Provider rental lifecycle | Public service methods delegate to one transaction that updates request, slot, owned dates, and notifications. |
| Notifications | Provider bell connected; rental_request → Provider Request Details; booking/payment → Player Booking Details; missing booking/payment references → My Bookings/Transaction History; message → Chat; review → existing review screen; exchange routes distinguish sender from recipient. |
| Messaging/exchange | Existing context chat reused from both booking sides. Existing exchange service, chat collections, message sending, and notification logic unchanged. |
| Reviews | Completed Booking Details entry; actual selected booking preselected; save checks ownership, completed status, equipment, and provider in a transaction. Edit/delete remain supported. |
| Ratings | Equipment Details derives live average/count from equipment reviews. Home/Search cards were not redesigned or given per-card review subscriptions; their Details destination displays the live rating. |
| Transactions | Preview records removed. Authenticated `payments.playerId` query, joined with owned `rental_requests` metadata. Payments/refunds retain status, method, amount, equipment/provider, reference/transaction ID and date. No withdrawal data used. |
| Location | New equipment uses saved `users.location` and real Provider name. Missing location prompts Edit Profile rather than substituting a location. Search uses `equipment.location`; old documents are not backfilled. |
| Equipment photo | Existing image_picker + Firebase Storage wired; preview, publishing/loading and error feedback retained. Upload path: `equipment_photos/{providerUid}/{equipmentId}/photo.{extension}`. iOS photo-library usage description added, but Firebase iOS configuration remains unsupported. |
| Authenticated services | Review, completed rentals, support, settings, profile, and shared Provider getters no longer read/write demo users when signed out. Stream-based reads propagate login errors instead of crashing at stream construction. |
| Listing deletion | Refuses blocking slots or owned reservations; verifies Provider ownership before deletion. |

## Availability and notifications

Collections remain `rental_requests`, `booking_slots`, and `equipment`.

New equipment bookkeeping adds `manualUnavailableDates` and `rentalReservations` (booking ID → dates). Existing `unavailableDates` remains the combined effective set consumed by the existing UI/models.

- pending: booking creation transaction writes request, slot, payment record, notifications, and its owned reservation together; competitors retry against the same equipment document and cannot persist an overlapping new reservation.
- accepted: own reservation stays blocked, slot becomes accepted, Provider fields including reservedDates stay compatible.
- active: handover flags and slot synchronize; dates stay blocked.
- completed: return checks remain mandatory; slot completes and only that booking's owned dates are released.
- rejected/cancelled: terminal slot status and owned-date release occur atomically. Player cancellation records the existing simulated-payment refund once using a deterministic refund document ID.
- manual dates and other bookings' dates survive release. Provider Availability cannot remove reservation-owned dates directly.
- repeated status actions can reconcile slots/date maps without duplicate notifications or refunds. Status notifications have deterministic booking/status/recipient IDs.

Legacy limitation: old `equipment.unavailableDates` may combine manual blocks and dates added by earlier accepted rentals with no provenance. Those ambiguous dates are preserved as manual blocks. They cannot be safely auto-cleared without reviewing/migrating actual data. Existing stale slots are reconciled on a lifecycle action; no remote bulk migration was performed.

## Remaining gap / live acceptance requirements

1. Follow-up: the Provider card now opens PublicProviderScreen with the selected provider ID. It reads public name/photo/location from users and equipment listings from equipment; listing taps return to Equipment Details. Live Firestore permissions still require device validation.
2. Live Firestore/Storage permissions were not verified. No rule files are present locally. The new transactional reservation/lifecycle paths require permission for the relevant authenticated equipment-reservation, slot, payment/refund, and notification writes. Rules must validate ownership and field changes; configuration was not invented or changed.
3. Photo picker/upload needs device and Storage permission testing. A permission failure produces an error and does not publish the listing. An upload that succeeds before a later listing write fails can leave an orphan photo; no unsafe remote cleanup was attempted.
4. Payments/refunds remain the existing simulated gateway plus Firestore records, not real money movement. Real payment-provider/server orchestration is outside these local fixes.
5. Firebase options configure Android and web only. iOS/macOS/Windows/Linux currently throw UnsupportedError. Protected Firebase configuration was left unchanged.
6. Legacy accepted rentals with ambiguous manually/reservation-blocked dates need a deliberate data review/migration. Existing listing locations are not retroactively invented.
7. Isolated `member3_preview.dart` still contains preview IDs and is not the production entrypoint. Production service authentication is now required; no fake-user access was reintroduced for previews.
8. Use Player A and Provider B to verify: booking visibility, Provider notification → request, accepted notification, identical context-chat IDs on both sides, send/receive/unread counts, handover/return, review edit/delete, actual history/refund display, reject/cancel release, simultaneous conflicting bookings, and photo upload. Repeat actions must not duplicate notifications/refunds.

## Firestore collections

Preserved: `users`, `equipment`, `rental_requests`, `booking_slots`, `payments`, `notifications`, `chats`, `chats/{chatId}/messages`, `exchange_requests`, `reviews`, `withdrawals`, `bank_accounts`, `support_reports`, and `favourites`.

## Modified files

- `mobile/ios/Runner/Info.plist`
- `mobile/lib/features/booking_payment/screens/booking/booking_details_screen.dart`
- `mobile/lib/features/booking_payment/services/booking_service.dart`
- `mobile/lib/features/exchange_messaging_profile/screens/notifications_screen.dart`
- `mobile/lib/features/exchange_messaging_profile/screens/rate_review_screen.dart`
- `mobile/lib/features/exchange_messaging_profile/screens/transaction_history_screen.dart`
- `mobile/lib/features/exchange_messaging_profile/services/completed_rental_service.dart`
- `mobile/lib/features/exchange_messaging_profile/services/profile_service.dart`
- `mobile/lib/features/exchange_messaging_profile/services/review_service.dart`
- `mobile/lib/features/exchange_messaging_profile/services/settings_service.dart`
- `mobile/lib/features/exchange_messaging_profile/services/support_service.dart`
- `mobile/lib/features/provider/screens/add_equipment_screen.dart`
- `mobile/lib/features/provider/screens/provider_dashboard.dart`
- `mobile/lib/features/provider/services/equipment_service.dart`
- `mobile/lib/features/provider/services/rental_request_service.dart`
- `mobile/lib/features/user_discovery/screens/equipment/equipment_details_screen.dart`
- `mobile/lib/features/user_discovery/services/auth_service.dart`
- `mobile/lib/services/auth_service.dart`

## Created files

- `mobile/android/.kotlin/sessions/kotlin-compiler-14644530743524992011.salive`
- `mobile/lib/features/booking_payment/services/booking_lifecycle_service.dart`
- `mobile/lib/features/exchange_messaging_profile/services/transaction_service.dart`
- `mobile/lib/navigation/notification_destination.dart`
- `mobile/test/booking_lifecycle_test.dart`
- `mobile/test/integration_destinations_test.dart`
- `docs/integration-audit.md`
