# Equipment ratings and reviews

The existing Equipment Details rating row now opens `RateReviewScreen` with the
selected listing's real equipment document ID and name. The row was extracted
unchanged into `EquipmentRating` so it can use the same `ReviewService` query and
average calculation as the page. Its colours, spacing and badge are preserved.
Equipment images, provider details, description, favourites and action buttons
retain their existing behavior.

The existing `RateReviewScreen` now accepts an optional `equipmentId`. This entry
point streams all matching documents in the existing `reviews` collection, shows
their average and count, and displays reviewer names from existing `users`
profiles, stars, comments and available timestamps. Deleted/private profiles use
`Rent Lanka User` instead of preventing review display. Empty, loading and error
states are distinct. No screen, service, model or collection is duplicated.

`ReviewService.watchEquipmentReviews` reuses the existing
`reviews.where('equipmentId', isEqualTo: equipmentId)` query. Dates are sorted in
memory so old documents without a creation date are still shown and no composite
index is required. Averages include valid persisted star ratings from 1 to 5;
an empty list shows N/A on the badge and No ratings yet on the page. Both receive
Firestore updates after create, edit or delete. There is no hardcoded rating,
equipment ID, or demo data.

`Write or manage your review` opens the same page's existing completed-rental
editor, filtered to the selected equipment. Existing entry points without an
equipment ID (including `initialBookingId`) continue to open that editor.
The existing rental-ownership validation, review IDs, create/update transaction
and delete service method are retained.

## Verification and Firebase access

Automated tests exercise the actual service and UI with controlled Firebase SDK
doubles: equipment query filtering, navigation and Back, name/comment/date
display, live averages/counts, empty/loading/error states, and the existing Add,
Edit and Delete buttons. Live Firebase and device behavior were not tested.

The reviews query already existed on Equipment Details. Existing rules must
allow intended viewers to read equipment reviews; the reviewer-name lookup uses
existing user-profile read permissions and falls back when access is denied.
No security rules were modified or deployed, and no deployed rules source was
available locally. Preserve existing owner-only review writes and completed-rental
eligibility. Do not broaden access to private profile data to display names.

For live verification, open a listing with reviews, tap its rating, check the
equipment-only list, average and count, and use Back to return to the listing.
With an eligible completed rental, submit, edit and delete a review through the
existing editor; both displays should update. Also check an equipment with no
reviews and a denied/offline read.

See [Firestore real-time listeners](https://firebase.google.com/docs/firestore/query-data/listen).
