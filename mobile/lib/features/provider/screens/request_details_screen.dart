import 'package:firebase_auth/firebase_auth.dart';
import '../../exchange_messaging_profile/screens/chat_screen.dart';
import '../../exchange_messaging_profile/services/chat_service.dart';
import 'package:flutter/material.dart';

import '../models/rental_request_model.dart';
import '../services/rental_request_service.dart';

import 'pickup_return_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  bool _openingChat = false;
  String get requestId => widget.requestId;

  Future<void> _messageUser(RentalRequestModel request) async {
    if (_openingChat) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showChatError('Please log in to message the player.');
      return;
    }
    if (request.providerId != user.uid) {
      _showChatError('This rental request does not belong to your account.');
      return;
    }
    if (request.playerId.isEmpty || request.playerId == user.uid) {
      _showChatError('This request has no valid player account to message.');
      return;
    }

    setState(() => _openingChat = true);
    try {
      final service = ChatService();
      // The request carries the player's name; no placeholder receiver is used.
      final playerName = request.playerName.trim();
      if (playerName.isEmpty) {
        throw Exception('Player name is missing from this request.');
      }
      final chatId = await service.ensureContextChat(
        providerId: request.providerId,
        playerId: request.playerId,
        playerName: playerName,
        equipmentId: request.equipmentId,
        equipmentName: request.equipmentName,
        rentalRequestId: request.id,
      );
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
        _showChatError('Your login changed. Please reopen the request.');
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(
          chatId: chatId,
          chatName: playerName,
          otherUserId: request.playerId,
          equipmentName: request.equipmentName,
          contextType: 'rental_request',
        )),
      );
    } catch (error) {
      if (!mounted) return;
      _showChatError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  void _showChatError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static const Color primaryRed =
      Color(0xFFED1235);

  static const Color textGrey =
      Color(0xFF8A8A8A);

  static final RentalRequestService
      _requestService =
      RentalRequestService();

  // =========================================================
  // ACCEPT REQUEST
  // =========================================================

  Future<void> _acceptRequest(
    BuildContext context,
    RentalRequestModel request,
  ) async {
    try {
      await _requestService.acceptRequest(
        request,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental request accepted and dates reserved.',
          ),
          backgroundColor:
              Color(0xFF27944A),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      String message = error.toString();

      message = message.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration:
              const Duration(seconds: 5),
        ),
      );
    }
  }

  // =========================================================
  // REJECT
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

    if (shouldReject != true ||
        !context.mounted) {
      return;
    }

    try {
      await _requestService.updateStatus(
        requestId: requestId,
        status: 'rejected',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental request rejected',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reject request: $error',
          ),
          backgroundColor: Colors.red,
        ),
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
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: StreamBuilder<
                RentalRequestModel?>(
              stream: _requestService
                  .watchRentalRequest(
                requestId,
              ),
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
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                final request =
                    snapshot.data;

                if (request == null) {
                  return const Center(
                    child: Text(
                      'Rental request not found.',
                    ),
                  );
                }

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
                      // ============================
                      // HEADER
                      // ============================

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
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // ============================
                      // USER CARD
                      // ============================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: const Color(
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
                                    request.playerName,
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),

                                  if (request
                                      .verifiedUser) ...[
                                    const SizedBox(
                                      height: 5,
                                    ),

                                    const Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .verified,
                                          size: 15,
                                          color:
                                              primaryRed,
                                        ),
                                        SizedBox(
                                          width: 5,
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
                              request.status,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ============================
                      // RENTAL DETAILS
                      // ============================

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          15,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: const Color(
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
                              request
                                  .equipmentName,
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              '${request.startDate} - ${request.endDate}',
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                color: textGrey,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Rs. ${_formatPrice(request.totalAmount)}',
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                color: primaryRed,
                                fontWeight:
                                    FontWeight.w800,
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
                                    text: request
                                        .pickupLocation,
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
                                    text: request
                                        .status
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                      color:
                                          _statusColor(
                                        request
                                            .status,
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

                      // ============================
                      // PENDING
                      // ============================

                      if (request.status ==
                          'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      () async {
                                    await _acceptRequest(
                                      context,
                                      request,
                                    );
                                  },
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
                                  child:
                                      const Text(
                                    'Accept Request',
                                    style:
                                        TextStyle(
                                      fontSize: 15,
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
                              child: SizedBox(
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
                                  child:
                                      const Text(
                                    'Reject',
                                    style:
                                        TextStyle(
                                      fontSize: 15,
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

                      // ============================
                      // ACCEPTED / ACTIVE
                      // ============================

                      if (request.status ==
                              'accepted' ||
                          request.status ==
                              'active') ...[
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFEAF8EF,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Text(
                            request.status ==
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
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child:
                              ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (
                                    context,
                                  ) =>
                                      PickupReturnScreen(
                                    requestId:
                                        requestId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.swap_horiz,
                            ),
                            label: const Text(
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

                      // ============================
                      // REJECTED
                      // ============================

                      if (request.status ==
                          'rejected')
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFFFEEF1,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Text(
                            'This rental request has been rejected.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color: primaryRed,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                      // ============================
                      // COMPLETED
                      // ============================

                      if (request.status ==
                          'completed')
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFF2F2F2,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Text(
                            'This rental has been completed.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ============================
                      // MESSAGE USER
                      // ============================

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child:
                            OutlinedButton.icon(
                          onPressed: _openingChat
                              ? null
                              : () => _messageUser(request),
                          icon: const Icon(
                            Icons
                                .chat_bubble_outline,
                          ),
                          label: const Text(
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
            const Color(0xFFEAF8EF);
        break;

      case 'rejected':
        background =
            const Color(0xFFFFEEF1);
        break;

      default:
        background =
            const Color(0xFFFFF4DD);
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
            BorderRadius.circular(20),
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