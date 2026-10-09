enum NotificationDestination {
  chat,
  review,
  exchange,
  providerRequest,
  booking,
  myBookings,
  transactions,
  none,
}

NotificationDestination notificationDestination(
  String type,
  String reference,
) => switch (type) {
  'message' =>
    reference.isEmpty
        ? NotificationDestination.none
        : NotificationDestination.chat,
  'review' => NotificationDestination.review,
  'exchange' =>
    reference.isEmpty
        ? NotificationDestination.none
        : NotificationDestination.exchange,
  'rental_request' =>
    reference.isEmpty
        ? NotificationDestination.none
        : NotificationDestination.providerRequest,
  'booking' =>
    reference.isEmpty
        ? NotificationDestination.myBookings
        : NotificationDestination.booking,
  'payment' =>
    reference.isEmpty
        ? NotificationDestination.transactions
        : NotificationDestination.booking,
  _ => NotificationDestination.none,
};

String notificationReference(Map<String, dynamic> data) {
  final reference = data['referenceId']?.toString().trim() ?? '';
  return reference.isEmpty
      ? data['bookingId']?.toString().trim() ?? ''
      : reference;
}
