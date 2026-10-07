import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../services/exchange_service.dart';
import 'chat_screen.dart';

class IncomingExchangeRequestScreen
    extends StatefulWidget {
  final String exchangeRequestId;

  const IncomingExchangeRequestScreen({
    super.key,
    required this.exchangeRequestId,
  });

  @override
  State<IncomingExchangeRequestScreen>
      createState() =>
          _IncomingExchangeRequestScreenState();
}

class _IncomingExchangeRequestScreenState
    extends State<IncomingExchangeRequestScreen> {
  static const Color primaryRed =
      Color(0xFFED1235);

  static const Color darkText =
      Color(0xFF242424);

  static const Color greyText =
      Color(0xFF7A7A7A);

  static const Color borderColor =
      Color(0xFFE6E6E6);

  static const Color backgroundColor =
      Color(0xFFF8F8F8);

  final ExchangeService _exchangeService =
      ExchangeService();

  final ChatService _chatService =
      ChatService();

  bool _isAccepting = false;
  bool _isRejecting = false;
  bool _isOpeningChat = false;

  Future<void> _respond(
    bool accept,
  ) async {
    final bool? confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: Text(
            accept
                ? 'Accept exchange?'
                : 'Decline exchange?',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            accept
                ? 'The requester will be notified that you accepted this exchange offer.'
                : 'The requester will be notified that you declined this exchange offer.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              child: Text(
                accept
                    ? 'Accept'
                    : 'Decline',
                style: TextStyle(
                  color: accept
                      ? const Color(
                          0xFF218548,
                        )
                      : primaryRed,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      if (accept) {
        _isAccepting = true;
      } else {
        _isRejecting = true;
      }
    });

    try {
      await _exchangeService
          .respondToExchangeRequest(
        exchangeRequestId:
            widget.exchangeRequestId,
        accept: accept,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Exchange request accepted.'
                : 'Exchange request declined.',
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Unable to update exchange request.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
          _isRejecting = false;
        });
      }
    }
  }

  Future<void> _messageRequester(
    String senderId,
  ) async {
    if (senderId.isEmpty) {
      _showMessage(
        'Requester information is missing.',
      );
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final String senderName =
          await _exchangeService
              .getUserDisplayName(
        senderId,
      );

      final String chatId =
          await _chatService.ensureChat(
        otherUserId: senderId,
        otherUserName: senderName,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            chatName: senderName,
            otherUserId: senderId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () =>
              Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Exchange Request',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<
            DocumentSnapshot<
                Map<String, dynamic>>>(
          stream: _exchangeService
              .watchExchangeRequest(
            widget.exchangeRequestId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState();
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

            if (!snapshot.hasData ||
                !snapshot.data!.exists) {
              return _buildNotFoundState();
            }

            final data =
                snapshot.data!.data();

            if (data == null) {
              return _buildNotFoundState();
            }

            final String senderId =
                data['senderId']
                        ?.toString() ??
                    '';

            final String requestedEquipment =
                data['requestedEquipmentName']
                        ?.toString() ??
                    'Requested equipment';

            final String offeredEquipment =
                data['offeredEquipmentName']
                        ?.toString() ??
                    'Offered equipment';

            final String message =
                data['message']
                        ?.toString()
                        .trim() ??
                    '';

            final String status =
                data['status']
                        ?.toString()
                        .toLowerCase() ??
                    'pending';

            final DateTime? createdAt =
                data['createdAt'] is Timestamp
                    ? (data['createdAt']
                            as Timestamp)
                        .toDate()
                        .toLocal()
                    : null;

            return Align(
              alignment:
                  Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 500,
                ),
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    20,
                    18,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _buildStatusCard(
                        status,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      FutureBuilder<String>(
                        future:
                            _exchangeService
                                .getUserDisplayName(
                          senderId,
                        ),
                        builder:
                            (context,
                                userSnapshot) {
                          final String
                              requesterName =
                              userSnapshot
                                      .data ??
                                  'Rent Lanka User';

                          return _buildRequesterCard(
                            requesterName,
                          );
                        },
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        'Exchange Offer',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildExchangeCard(
                        requestedEquipment:
                            requestedEquipment,
                        offeredEquipment:
                            offeredEquipment,
                      ),

                      if (message
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 24,
                        ),
                        const Text(
                          'Message',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(16),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                            border:
                                Border.all(
                              color:
                                  borderColor,
                            ),
                          ),
                          child: Text(
                            message,
                            style:
                                const TextStyle(
                              color:
                                  darkText,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 20,
                      ),

                      _buildDateCard(
                        createdAt,
                      ),

                      const SizedBox(
                        height: 26,
                      ),

                      if (status ==
                          'pending')
                        _buildDecisionButtons(),

                      if (status !=
                          'pending')
                        _buildCompletedMessage(
                          status,
                        ),

                      if (status ==
                              'accepted' &&
                          senderId
                              .isNotEmpty) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          height: 54,
                          child:
                              OutlinedButton
                                  .icon(
                            onPressed:
                                _isOpeningChat
                                    ? null
                                    : () =>
                                        _messageRequester(
                                          senderId,
                                        ),
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  primaryRed,
                              side:
                                  const BorderSide(
                                color:
                                    primaryRed,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            icon:
                                _isOpeningChat
                                    ? const SizedBox(
                                        width:
                                            20,
                                        height:
                                            20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              primaryRed,
                                        ),
                                      )
                                    : const Icon(
                                        Icons
                                            .chat_bubble_outline_rounded,
                                      ),
                            label:
                                const Text(
                              'Message Requester',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequesterCard(
    String requesterName,
  ) {
    final String letter =
        requesterName.trim().isEmpty
            ? '?'
            : requesterName
                .trim()[0]
                .toUpperCase();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(
              color: Color(0xFFFFE9ED),
              shape: BoxShape.circle,
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: primaryRed,
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request from',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requesterName,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard({
    required String requestedEquipment,
    required String offeredEquipment,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _buildEquipmentRow(
            label: 'They want',
            name: requestedEquipment,
            icon:
                Icons.sports_cricket_rounded,
            background:
                const Color(0xFFFFEEF1),
            iconColor: primaryRed,
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: borderColor,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Icon(
                    Icons
                        .swap_vert_rounded,
                    color: primaryRed,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: borderColor,
                  ),
                ),
              ],
            ),
          ),

          _buildEquipmentRow(
            label: 'They offer',
            name: offeredEquipment,
            icon:
                Icons.inventory_2_outlined,
            background:
                const Color(0xFFEDF4FF),
            iconColor:
                const Color(0xFF3478C7),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentRow({
    required String label,
    required String name,
    required IconData icon,
    required Color background,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: background,
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                name,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed:
                  _isAccepting ||
                          _isRejecting
                      ? null
                      : () =>
                          _respond(false),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    primaryRed,
                side: const BorderSide(
                  color: primaryRed,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: _isRejecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryRed,
                      ),
                    )
                  : const Text(
                      'Decline',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed:
                  _isAccepting ||
                          _isRejecting
                      ? null
                      : () =>
                          _respond(true),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF218548,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: _isAccepting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Text(
                      'Accept',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String status,
  ) {
    Color background;
    Color foreground;
    IconData icon;
    String text;

    switch (status) {
      case 'accepted':
        background =
            const Color(0xFFE9F8EE);
        foreground =
            const Color(0xFF218548);
        icon =
            Icons.check_circle_rounded;
        text = 'Accepted';
        break;

      case 'rejected':
        background =
            const Color(0xFFFFEAEA);
        foreground =
            const Color(0xFFC83939);
        icon = Icons.cancel_rounded;
        text = 'Declined';
        break;

      case 'cancelled':
        background =
            const Color(0xFFF0F0F0);
        foreground =
            const Color(0xFF666666);
        icon = Icons.block_rounded;
        text = 'Cancelled';
        break;

      default:
        background =
            const Color(0xFFFFF6DD);
        foreground =
            const Color(0xFFB97900);
        icon = Icons.schedule_rounded;
        text =
            'Waiting for your response';
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(
    DateTime? date,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .calendar_today_outlined,
            color: primaryRed,
            size: 19,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Requested on',
              style: TextStyle(
                color: greyText,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            _formatDate(date),
            style: const TextStyle(
              color: darkText,
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedMessage(
    String status,
  ) {
    String text;

    if (status == 'accepted') {
      text =
          'You accepted this exchange offer.';
    } else if (status == 'rejected') {
      text =
          'You declined this exchange offer.';
    } else if (status == 'cancelled') {
      text =
          'The requester cancelled this exchange request.';
    } else {
      text =
          'This exchange request has been updated.';
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: darkText,
          fontSize: 14,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Unable to load exchange request.',
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Center(
      child: Text(
        'Exchange request not found.',
      ),
    );
  }

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Just now';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}