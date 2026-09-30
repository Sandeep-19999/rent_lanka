import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pickup_return_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  static const Color primaryRed = Color(0xFFED1235);
  static const Color textGrey = Color(0xFF8A8A8A);

  // =========================================================
  // UPDATE STATUS
  // Mainly used for rejection
  // =========================================================
  Future<void> _updateStatus(
    BuildContext context,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(requestId)
          .update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'rejected'
                ? 'Rental request rejected'
                : 'Request updated successfully',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update request: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // ACCEPT REQUEST
  //
  // 1. Validate request data
  // 2. Read equipment
  // 3. Check unavailable dates
  // 4. If no conflict, reserve requested dates
  // 5. Change request status to accepted
  // =========================================================
  Future<void> _acceptRequest(
    BuildContext context,
    Map<String, dynamic> requestData,
  ) async {
    try {
      final String equipmentId =
          requestData['equipmentId']?.toString().trim() ?? '';

      final String startDate =
          requestData['startDate']?.toString().trim() ?? '';

      final String endDate =
          requestData['endDate']?.toString().trim() ?? '';

      // -----------------------------
      // Basic validation
      // -----------------------------
      if (equipmentId.isEmpty ||
          startDate.isEmpty ||
          endDate.isEmpty) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Request information is incomplete.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final DateTime? start =
          DateTime.tryParse(startDate);

      final DateTime? end =
          DateTime.tryParse(endDate);

      if (start == null || end == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid rental dates.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      if (start.isAfter(end)) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Start date cannot be after end date.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // -----------------------------
      // Create requested date list
      // -----------------------------
      final List<String> requestedDates = [];

      DateTime currentDate = DateTime(
        start.year,
        start.month,
        start.day,
      );

      final DateTime finalDate = DateTime(
        end.year,
        end.month,
        end.day,
      );

      while (!currentDate.isAfter(finalDate)) {
        requestedDates.add(
          _formatDate(currentDate),
        );

        currentDate = currentDate.add(
          const Duration(days: 1),
        );
      }

      final equipmentRef =
          FirebaseFirestore.instance
              .collection('equipment')
              .doc(equipmentId);

      final requestRef =
          FirebaseFirestore.instance
              .collection('rental_requests')
              .doc(requestId);

      // =====================================================
      // TRANSACTION
      //
      // This prevents two requests from being accepted
      // for the same equipment dates at nearly the same time.
      // =====================================================
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final equipmentSnapshot =
              await transaction.get(
            equipmentRef,
          );

          if (!equipmentSnapshot.exists) {
            throw Exception(
              'Equipment could not be found.',
            );
          }

          final equipmentData =
              equipmentSnapshot.data() ?? {};

          final bool isAvailable =
              equipmentData['isAvailable'] != false;

          if (!isAvailable) {
            throw Exception(
              'This equipment is currently unavailable.',
            );
          }

          // -----------------------------------------------
          // Existing unavailable dates
          // -----------------------------------------------
          final dynamic unavailableValue =
              equipmentData['unavailableDates'];

          final Set<String> unavailableDates =
              {};

          if (unavailableValue is List) {
            unavailableDates.addAll(
              unavailableValue.map(
                (date) => date.toString(),
              ),
            );
          }

          // -----------------------------------------------
          // Check for conflicts
          // -----------------------------------------------
          final List<String> conflictDates =
              requestedDates
                  .where(
                    (date) =>
                        unavailableDates.contains(
                      date,
                    ),
                  )
                  .toList();

          if (conflictDates.isNotEmpty) {
            throw Exception(
              'Equipment is unavailable on '
              '${conflictDates.join(', ')}.',
            );
          }

          // -----------------------------------------------
          // Make sure request is still pending
          // -----------------------------------------------
          final requestSnapshot =
              await transaction.get(
            requestRef,
          );

          if (!requestSnapshot.exists) {
            throw Exception(
              'Rental request could not be found.',
            );
          }

          final requestFirestoreData =
              requestSnapshot.data() ?? {};

          final String currentStatus =
              requestFirestoreData['status']
                      ?.toString()
                      .toLowerCase() ??
                  'pending';

          if (currentStatus != 'pending') {
            throw Exception(
              'This request has already been updated.',
            );
          }

          // -----------------------------------------------
          // Reserve equipment dates
          // -----------------------------------------------
          transaction.update(
            equipmentRef,
            {
              'unavailableDates':
                  FieldValue.arrayUnion(
                requestedDates,
              ),
              'availabilityUpdatedAt':
                  FieldValue.serverTimestamp(),
            },
          );

          // -----------------------------------------------
          // Accept rental request
          // -----------------------------------------------
          transaction.update(
            requestRef,
            {
              'status': 'accepted',

              'reservedDates':
                  requestedDates,

              'statusUpdatedAt':
                  FieldValue.serverTimestamp(),

              'availabilityCheckedAt':
                  FieldValue.serverTimestamp(),

              'datesReservedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        },
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental request accepted and dates reserved.',
          ),
          backgroundColor: Color(
            0xFF27944A,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      String message =
          error.toString();

      // Remove "Exception:" from message
      message = message.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(
            seconds: 5,
          ),
        ),
      );
    }
  }

  // =========================================================
  // REJECT REQUEST DIALOG
  // =========================================================
  Future<void> _showRejectDialog(
    BuildContext context,
  ) async {
    final bool? shouldReject =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject request?',
          ),
          content: const Text(
            'Are you sure you want to reject this rental request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: primaryRed,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReject == true &&
        context.mounted) {
      await _updateStatus(
        context,
        'rejected',
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: StreamBuilder<
                DocumentSnapshot<
                    Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(
                    'rental_requests',
                  )
                  .doc(requestId)
                  .snapshots(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        'Something went wrong:\n'
                        '${snapshot.error}',
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'Rental request not found.',
                    ),
                  );
                }

                final Map<String, dynamic> data =
                    snapshot.data!.data()!;

                final String playerName =
                    data['playerName']
                            ?.toString() ??
                        'Player';

                final String equipmentName =
                    data['equipmentName']
                            ?.toString() ??
                        'Equipment';

                final String startDate =
                    data['startDate']
                            ?.toString() ??
                        '';

                final String endDate =
                    data['endDate']
                            ?.toString() ??
                        '';

                final String pickupLocation =
                    data['pickupLocation']
                            ?.toString() ??
                        'Provider location';

                final dynamic verifiedValue =
                    data['verifiedUser'];

                final bool verifiedUser =
                    verifiedValue == true ||
                        verifiedValue
                                ?.toString()
                                .toLowerCase() ==
                            'true';

                final String status =
                    data['status']
                            ?.toString()
                            .toLowerCase() ??
                        'pending';

                final dynamic amountValue =
                    data['totalAmount'];

                final double totalAmount =
                    amountValue is num
                        ? amountValue
                            .toDouble()
                        : 0;

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =================================================
                      // HEADER
                      // =================================================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            padding:
                                EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(),
                            icon: const Icon(
                              Icons
                                  .arrow_back_ios_new,
                              size: 22,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          const Text(
                            'Request Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =================================================
                      // USER CARD
                      // =================================================
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFFDDDDDD,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  Color(
                                0xFFEAEAEA,
                              ),
                              child: Icon(
                                Icons.person,
                                color:
                                    Colors.black54,
                                size: 28,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    playerName,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),

                                  if (verifiedUser)
                                    ...[
                                      const SizedBox(
                                        height:
                                            5,
                                      ),

                                      const Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .verified,
                                            size:
                                                15,
                                            color:
                                                primaryRed,
                                          ),

                                          SizedBox(
                                            width:
                                                5,
                                          ),

                                          Text(
                                            'Verified user',
                                            style:
                                                TextStyle(
                                              fontSize:
                                                  13,
                                              color:
                                                  primaryRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                ],
                              ),
                            ),

                            _statusBadge(
                              status,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // =================================================
                      // RENTAL DETAILS
                      // =================================================
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets.all(
                          15,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFFDDDDDD,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              equipmentName,
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              '$startDate - $endDate',
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                color:
                                    textGrey,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Rs. ${_formatPrice(totalAmount)}',
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                color:
                                    primaryRed,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            const Divider(
                              height: 1,
                              color: Color(
                                0xFFE5E5E5,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Text.rich(
                              TextSpan(
                                style:
                                    const TextStyle(
                                  fontSize: 14,
                                  color: Color(
                                    0xFF333333,
                                  ),
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'Pickup requested: ',
                                  ),
                                  TextSpan(
                                    text:
                                        pickupLocation,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Text.rich(
                              TextSpan(
                                style:
                                    const TextStyle(
                                  fontSize: 14,
                                  color: Color(
                                    0xFF333333,
                                  ),
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'Status: ',
                                  ),
                                  TextSpan(
                                    text: status
                                        .toUpperCase(),
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                      color:
                                          _statusColor(
                                        status,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =================================================
                      // PENDING REQUEST
                      // =================================================
                      if (status ==
                          'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child:
                                  SizedBox(
                                height: 52,
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      () async {
                                    await _acceptRequest(
                                      context,
                                      data,
                                    );
                                  },
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        primaryRed,
                                    foregroundColor:
                                        Colors
                                            .white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        9,
                                      ),
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'Accept Request',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          15,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child:
                                  SizedBox(
                                height: 52,
                                child:
                                    OutlinedButton(
                                  onPressed: () {
                                    _showRejectDialog(
                                      context,
                                    );
                                  },
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        Colors
                                            .black,
                                    side:
                                        const BorderSide(
                                      color:
                                          Color(
                                        0xFFDADADA,
                                      ),
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        9,
                                      ),
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'Reject',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          15,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // =================================================
                      // ACCEPTED / ACTIVE
                      // =================================================
                      if (status ==
                              'accepted' ||
                          status ==
                              'active') ...[
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEAF8EF,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: Text(
                            status ==
                                    'accepted'
                                ? 'This rental request has been accepted.'
                                : 'This rental is currently active.',
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color: Color(
                                0xFF27944A,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PickupReturnScreen(
                                    requestId:
                                        requestId,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .swap_horiz,
                            ),
                            label:
                                const Text(
                              'Open Pickup & Return',
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryRed,
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // =================================================
                      // REJECTED
                      // =================================================
                      if (status ==
                          'rejected')
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFFEEF1,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child:
                              const Text(
                            'This rental request has been rejected.',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  primaryRed,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),

                      // =================================================
                      // COMPLETED
                      // =================================================
                      if (status ==
                          'completed')
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF2F2F2,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child:
                              const Text(
                            'This rental has been completed.',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =================================================
                      // MESSAGE USER
                      // =================================================
                      SizedBox(
                        width:
                            double.infinity,
                        height: 52,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Message screen will be connected later.',
                                ),
                              ),
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .chat_bubble_outline,
                          ),
                          label:
                              const Text(
                            'Message user',
                          ),
                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                Colors.black,
                            side:
                                const BorderSide(
                              color: Color(
                                0xFFDADADA,
                              ),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================
  static Widget _statusBadge(
    String status,
  ) {
    final Color color =
        _statusColor(status);

    Color background;

    switch (status) {
      case 'accepted':
      case 'active':
      case 'completed':
        background =
            const Color(
          0xFFEAF8EF,
        );
        break;

      case 'rejected':
        background =
            const Color(
          0xFFFFEEF1,
        );
        break;

      default:
        background =
            const Color(
          0xFFFFF4DD,
        );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  // =========================================================
  // STATUS COLOR
  // =========================================================
  static Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'accepted':
      case 'active':
      case 'completed':
        return const Color(
          0xFF27944A,
        );

      case 'rejected':
        return primaryRed;

      default:
        return const Color(
          0xFFC47A00,
        );
    }
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================
  static String _formatDate(
    DateTime date,
  ) {
    final String year =
        date.year
            .toString()
            .padLeft(
              4,
              '0',
            );

    final String month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$year-$month-$day';
  }

  // =========================================================
  // FORMAT PRICE
  // =========================================================
  static String _formatPrice(
    double price,
  ) {
    if (price ==
        price.roundToDouble()) {
      return price
          .toInt()
          .toString();
    }

    return price.toStringAsFixed(
      2,
    );
  }
}