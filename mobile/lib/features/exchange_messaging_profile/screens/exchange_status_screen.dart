import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import '../services/exchange_service.dart';
import 'chat_screen.dart';

class ExchangeStatusScreen extends StatefulWidget {
  final String exchangeRequestId;

  const ExchangeStatusScreen({
    super.key,
    required this.exchangeRequestId,
  });

  @override
  State<ExchangeStatusScreen> createState() => _ExchangeStatusScreenState();
}

class _ExchangeStatusScreenState extends State<ExchangeStatusScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7A7A7A);
  static const Color borderColor = Color(0xFFE6E6E6);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  final ExchangeService _exchangeService = ExchangeService();
  final ChatService _chatService = ChatService();

  bool _isOpeningChat = false;
  bool _isCancelling = false;

  Future<void> _messageProvider(String providerId) async {
    if (providerId.trim().isEmpty) {
      _showMessage('Provider information is missing.');
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final providerName = await _chatService.getUserDisplayName(
        providerId,
      );

      final chatId = await _chatService.ensureChat(
        otherUserId: providerId,
        otherUserName: providerName,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            chatName: providerName,
            otherUserId: providerId,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ?? 'Unable to open chat.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Exchange Status',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child:
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _exchangeService.watchExchangeRequest(
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
                    child: CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildNotFoundState();
                }

                final data = snapshot.data!.data();

                if (data == null) {
                  return _buildNotFoundState();
                }

                final String requestedEquipment =
                    data['requestedEquipmentName']?.toString() ??
                        'Requested equipment';

                final String offeredEquipment =
                    data['offeredEquipmentName']?.toString() ??
                        'Offered equipment';

                final String providerId =
                    data['requestedProviderId']?.toString() ?? '';

                final String message =
                    data['message']?.toString().trim() ?? '';

                final String status =
                    data['status']?.toString().toLowerCase() ??
                        'pending';

                final Timestamp? createdTimestamp =
                    data['createdAt'] is Timestamp
                        ? data['createdAt'] as Timestamp
                        : null;

                final DateTime? createdAt =
                    createdTimestamp?.toDate();

                final bool canMessage =
                    status != 'cancelled' &&
                    status != 'rejected' &&
                    providerId.isNotEmpty;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildStatusBanner(status),

                      const SizedBox(height: 24),

                      const Text(
                        'Exchange Summary',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildExchangeSummary(
                        requestedEquipment:
                            requestedEquipment,
                        offeredEquipment: offeredEquipment,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Request Progress',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildProgress(status),

                      const SizedBox(height: 24),

                      const Text(
                        'Request Details',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildDetailsCard(
                        createdAt: createdAt,
                        message: message,
                      ),

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isOpeningChat || !canMessage
                                  ? null
                                  : () =>
                                      _messageProvider(providerId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFE4E4E4),
                            disabledForegroundColor:
                                const Color(0xFF999999),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isOpeningChat
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isOpeningChat
                                ? 'Opening Chat...'
                                : status == 'rejected' ||
                                        status == 'cancelled'
                                    ? 'Messaging Unavailable'
                                    : 'Message Provider',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      if (status == 'pending') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _isCancelling
                                ? null
                                : _showCancelDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: darkText,
                              side: const BorderSide(
                                color: borderColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: _isCancelling
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
                                    'Cancel Request',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  Widget _buildStatusBanner(String status) {
    final Color color = _statusTextColor(status);
    final Color background = _statusBackgroundColor(status);
    final IconData icon = _statusIcon(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _statusTitle(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusDescription(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeSummary({
    required String requestedEquipment,
    required String offeredEquipment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildEquipmentRow(
            icon: Icons.sports_cricket_rounded,
            label: 'You want',
            equipmentName: requestedEquipment,
            iconBackground: const Color(0xFFFFEEF1),
            iconColor: primaryRed,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: borderColor),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    color: primaryRed,
                    size: 25,
                  ),
                ),
                Expanded(
                  child: Divider(color: borderColor),
                ),
              ],
            ),
          ),

          _buildEquipmentRow(
            icon: Icons.inventory_2_outlined,
            label: 'You offer',
            equipmentName: offeredEquipment,
            iconBackground: const Color(0xFFF0F7FF),
            iconColor: const Color(0xFF3478C7),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentRow({
    required IconData icon,
    required String label,
    required String equipmentName,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
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
                equipmentName,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(String status) {
    final bool submitted = true;

    final bool reviewed =
        status != 'pending' && status != 'cancelled';

    final bool decided =
        status == 'accepted' ||
        status == 'rejected' ||
        status == 'completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildProgressItem(
            title: 'Request submitted',
            subtitle:
                'Your exchange offer was sent.',
            isComplete: submitted,
            showLine: true,
          ),
          _buildProgressItem(
            title: 'Provider review',
            subtitle: status == 'pending'
                ? 'Waiting for the provider to review your offer.'
                : 'The provider reviewed your offer.',
            isComplete: reviewed,
            showLine: true,
          ),
          _buildProgressItem(
            title: 'Decision',
            subtitle: _decisionProgressText(status),
            isComplete: decided,
            showLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required String subtitle,
    required bool isComplete,
    required bool showLine,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? primaryRed
                        : const Color(0xFFE8E8E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isComplete
                        ? Icons.check_rounded
                        : Icons.circle,
                    size: isComplete ? 15 : 7,
                    color: isComplete
                        ? Colors.white
                        : const Color(0xFFAAAAAA),
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      color: isComplete
                          ? primaryRed
                              .withValues(alpha: 0.25)
                          : const Color(0xFFE8E8E8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isComplete
                          ? darkText
                          : const Color(0xFF999999),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard({
    required DateTime? createdAt,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Requested on',
            _formatDate(createdAt),
          ),
          if (message.isNotEmpty) ...[
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                height: 1,
                color: borderColor,
              ),
            ),
            const Text(
              'Your message',
              style: TextStyle(
                color: greyText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryRed,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: greyText,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelDialog() async {
    final bool? shouldCancel =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Cancel exchange request?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'The provider will no longer be able to accept this exchange request.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text(
                'Keep Request',
                style: TextStyle(
                  color: darkText,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text(
                'Cancel Request',
                style: TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await _exchangeService.cancelExchangeRequest(
        widget.exchangeRequestId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Exchange request cancelled.'),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Unable to cancel request.',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: primaryRed,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load exchange request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () =>
                  Navigator.maybePop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: 58,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            const Text(
              'Exchange request not found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () =>
                  Navigator.maybePop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'accepted':
        return 'Exchange Accepted';
      case 'rejected':
        return 'Exchange Declined';
      case 'cancelled':
        return 'Request Cancelled';
      case 'completed':
        return 'Exchange Completed';
      default:
        return 'Waiting for Response';
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'accepted':
        return 'The provider accepted your offer. You can now contact them to arrange the exchange.';
      case 'rejected':
        return 'The provider declined this exchange offer.';
      case 'cancelled':
        return 'You cancelled this exchange request.';
      case 'completed':
        return 'This equipment exchange has been completed.';
      default:
        return 'Your request has been sent. The provider has not responded yet.';
    }
  }

  String _decisionProgressText(String status) {
    switch (status) {
      case 'accepted':
        return 'Your exchange offer was accepted.';
      case 'rejected':
        return 'Your exchange offer was declined.';
      case 'completed':
        return 'The exchange was completed.';
      case 'cancelled':
        return 'The request was cancelled.';
      default:
        return 'Waiting for a decision.';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status) {
      case 'accepted':
      case 'completed':
        return const Color(0xFFE9F8EE);
      case 'rejected':
        return const Color(0xFFFFEAEA);
      case 'cancelled':
        return const Color(0xFFF0F0F0);
      default:
        return const Color(0xFFFFF6DD);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'accepted':
      case 'completed':
        return const Color(0xFF218548);
      case 'rejected':
        return const Color(0xFFC83939);
      case 'cancelled':
        return const Color(0xFF666666);
      default:
        return const Color(0xFFB97900);
    }
  }

  String _formatDate(DateTime? date) {
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