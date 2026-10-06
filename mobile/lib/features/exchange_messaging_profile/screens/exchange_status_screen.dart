import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/exchange_service.dart';

class ExchangeStatusScreen extends StatelessWidget {
  final String exchangeRequestId;

  const ExchangeStatusScreen({super.key, required this.exchangeRequestId});

  static const Color primaryRed = Color(0xFFED1235);

  @override
  Widget build(BuildContext context) {
    final ExchangeService exchangeService = ExchangeService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: exchangeService.watchExchangeRequest(exchangeRequestId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(context);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildNotFoundState(context);
                }

                final data = snapshot.data!.data();

                if (data == null) {
                  return _buildNotFoundState(context);
                }

                final String requestedEquipment =
                    data['requestedEquipmentName']?.toString() ??
                    'Requested equipment';

                final String offeredEquipment =
                    data['offeredEquipmentName']?.toString() ??
                    'Offered equipment';

                final String status = data['status']?.toString() ?? 'pending';

                final Timestamp? createdTimestamp =
                    data['createdAt'] is Timestamp
                    ? data['createdAt'] as Timestamp
                    : null;

                final DateTime? createdAt = createdTimestamp?.toDate();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),

                      const SizedBox(height: 28),

                      _buildExchangeCard(
                        requestedEquipment: requestedEquipment,
                        offeredEquipment: offeredEquipment,
                        status: status,
                      ),

                      const SizedBox(height: 26),

                      Text(
                        'Requested: ${_formatDate(createdAt)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF969696),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Chat screen will be connected next.',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Message provider',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: status == 'pending'
                              ? () =>
                                    _showCancelDialog(context, exchangeService)
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF242424),
                            disabledForegroundColor: const Color(0xFFAAAAAA),
                            side: BorderSide(
                              color: status == 'pending'
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFEAEAEA),
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            status == 'cancelled'
                                ? 'Request cancelled'
                                : 'Cancel request',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: Color(0xFF242424),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Exchange status',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeCard({
    required String requestedEquipment,
    required String offeredEquipment,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$requestedEquipment ↔ $offeredEquipment',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF242424),
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBackgroundColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _statusText(status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _statusTextColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    ExchangeService exchangeService,
  ) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel exchange request?'),
          content: const Text(
            'Are you sure you want to cancel this exchange request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Yes, cancel',
                style: TextStyle(color: primaryRed),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      await exchangeService.cancelExchangeRequest(exchangeRequestId);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exchange request cancelled.')),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to cancel request.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel request: $error')),
      );
    }
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: primaryRed),
          const SizedBox(height: 15),
          const Text(
            'Unable to load exchange request.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.swap_horiz, size: 55, color: Color(0xFF999999)),
          const SizedBox(height: 15),
          const Text(
            'Exchange request not found.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'pending':
      default:
        return 'Pending provider response';
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        return const Color(0xFFE7F7EC);

      case 'rejected':
        return const Color(0xFFFFE7E7);

      case 'cancelled':
        return const Color(0xFFECECEC);

      case 'pending':
      default:
        return const Color(0xFFFFF6D9);
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        return const Color(0xFF228B45);

      case 'rejected':
        return const Color(0xFFD93025);

      case 'cancelled':
        return const Color(0xFF666666);

      case 'pending':
      default:
        return const Color(0xFFFFB000);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }

    const List<String> months = [
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
