import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/exchange_service.dart';
import 'exchange_status_screen.dart';
import 'incoming_exchange_request_screen.dart';

class MyExchangesScreen extends StatefulWidget {
  final bool showReceivedFirst;
  const MyExchangesScreen({super.key, this.showReceivedFirst = false});

  @override
  State<MyExchangesScreen> createState() => _MyExchangesScreenState();
}

class _MyExchangesScreenState extends State<MyExchangesScreen> {
  final _service = ExchangeService();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _sent;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _received;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _sent = _service.watchMySentExchangeRequests();
    _received = _service.watchIncomingExchangeRequests();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    initialIndex: widget.showReceivedFirst ? 1 : 0,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: const Text('My Exchanges'),
        bottom: const TabBar(
          labelColor: Color(0xFFED1235),
          indicatorColor: Color(0xFFED1235),
          tabs: [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(children: [_list(_sent, false), _list(_received, true)]),
    ),
  );

  Widget _list(
    Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    bool received,
  ) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unable to load exchanges. Please check your connection and login.',
              ),
              TextButton(
                onPressed: () => setState(_load),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final docs = [...snapshot.data!.docs];
      docs.sort((a, b) {
        final first = a.data()['createdAt'];
        final second = b.data()['createdAt'];
        return (second is Timestamp ? second.millisecondsSinceEpoch : 0)
            .compareTo(first is Timestamp ? first.millisecondsSinceEpoch : 0);
      });
      if (docs.isEmpty) {
        return Center(
          child: Text(
            received
                ? 'No exchange requests received yet.'
                : 'You have not sent any exchange requests yet.',
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: docs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data();
          final wanted =
              data['requestedEquipmentName']?.toString() ?? 'Equipment';
          final offered =
              data['offeredEquipmentName']?.toString() ?? 'Equipment';
          final status =
              data['status']?.toString().trim().toLowerCase() ?? 'pending';
          final image = data['offeredEquipmentImageUrl']?.toString() ?? '';
          final color = status == 'accepted'
              ? Colors.green
              : status == 'pending'
              ? Colors.orange
              : Colors.grey;
          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => received
                      ? IncomingExchangeRequestScreen(exchangeRequestId: doc.id)
                      : ExchangeStatusScreen(exchangeRequestId: doc.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: image.isEmpty
                            ? const Icon(
                                Icons.swap_horiz,
                                color: Color(0xFFED1235),
                              )
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.swap_horiz),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wanted,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Offered: $offered',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            status.isEmpty
                                ? 'Pending'
                                : '${status[0].toUpperCase()}${status.substring(1)}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
