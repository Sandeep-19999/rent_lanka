import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class EquipmentPerformanceScreen extends StatelessWidget {
  const EquipmentPerformanceScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('equipment')
                  .where(
                    'providerId',
                    isEqualTo: AuthService.providerId,
                  )
                  .snapshots(),
              builder: (
                context,
                equipmentSnapshot,
              ) {
                if (equipmentSnapshot.hasError) {
                  return _errorScreen(
                    'Failed to load equipment data.',
                  );
                }

                return StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('rental_requests')
                      .where(
                        'providerId',
                        isEqualTo: AuthService.providerId,
                      )
                      .snapshots(),
                  builder: (
                    context,
                    rentalSnapshot,
                  ) {
                    if (rentalSnapshot.hasError) {
                      return _errorScreen(
                        'Failed to load rental performance.',
                      );
                    }

                    if (!equipmentSnapshot.hasData ||
                        !rentalSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryRed,
                        ),
                      );
                    }

                    final equipmentDocuments =
                        equipmentSnapshot.data!.docs;

                    final rentalDocuments =
                        rentalSnapshot.data!.docs;

                    final int equipmentCount =
                        equipmentDocuments.length;

                    int completedRentals = 0;
                    int activeRentals = 0;

                    double totalRevenue = 0;

                    final Map<String, _EquipmentStats>
                        equipmentStats = {};

                    for (final document
                        in equipmentDocuments) {
                      final data =
                          document.data();

                      final String name =
                          data['name']
                                  ?.toString() ??
                              'Equipment';

                      equipmentStats[
                              document.id] =
                          _EquipmentStats(
                        equipmentId:
                            document.id,
                        name: name,
                      );
                    }

                    for (final request
                        in rentalDocuments) {
                      final data =
                          request.data();

                      final String status =
                          data['status']
                                  ?.toString()
                                  .toLowerCase() ??
                              '';

                      final String equipmentId =
                          data['equipmentId']
                                  ?.toString() ??
                              '';

                      final String equipmentName =
                          data['equipmentName']
                                  ?.toString() ??
                              'Equipment';

                      if (status == 'active') {
                        activeRentals++;
                      }

                      if (status ==
                          'completed') {
                        completedRentals++;

                        final amount =
                            data['totalAmount'];

                        final double value =
                            amount is num
                                ? amount
                                    .toDouble()
                                : 0;

                        totalRevenue +=
                            value;

                        if (!equipmentStats
                            .containsKey(
                          equipmentId,
                        )) {
                          equipmentStats[
                                  equipmentId] =
                              _EquipmentStats(
                            equipmentId:
                                equipmentId,
                            name:
                                equipmentName,
                          );
                        }

                        final stats =
                            equipmentStats[
                                equipmentId];

                        if (stats != null) {
                          stats.rentals++;
                          stats.revenue +=
                              value;
                        }
                      }
                    }

                    final List<_EquipmentStats>
                        rankedEquipment =
                        equipmentStats.values
                            .where(
                              (item) =>
                                  item.rentals >
                                  0,
                            )
                            .toList()
                          ..sort(
                            (a, b) => b.rentals
                                .compareTo(
                              a.rentals,
                            ),
                          );

                    final topThree =
                        rankedEquipment
                            .take(3)
                            .toList();

                    return _buildContent(
                      context: context,
                      equipmentCount:
                          equipmentCount,
                      completedRentals:
                          completedRentals,
                      activeRentals:
                          activeRentals,
                      totalRevenue:
                          totalRevenue,
                      topEquipment:
                          topThree,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required int equipmentCount,
    required int completedRentals,
    required int activeRentals,
    required double totalRevenue,
    required List<_EquipmentStats>
        topEquipment,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              const Text(
                'Equipment Performance',
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

          // ===============================================
          // PERFORMANCE CHART
          // ===============================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color: const Color(
                  0xFFE5E5E5,
                ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter:
                        _RentalDonutPainter(
                      equipment:
                          topEquipment,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Text(
                            'Total Rentals',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            '$completedRentals',
                            style:
                                const TextStyle(
                              fontSize: 27,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                if (topEquipment.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.all(
                      15,
                    ),
                    child: Text(
                      'No completed rental data yet.',
                      style: TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    topEquipment.length,
                    (index) {
                      final item =
                          topEquipment[
                              index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),
                        child: _LegendRow(
                          index: index,
                          name: item.name,
                          rentals:
                              item.rentals,
                          revenue:
                              item.revenue,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          // ===============================================
          // STAT CARDS
          // ===============================================
          Row(
            children: [
              Expanded(
                child:
                    _PerformanceCard(
                  title:
                      'Listed Equipment',
                  value:
                      '$equipmentCount',
                  icon: Icons
                      .inventory_2_outlined,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _PerformanceCard(
                  title:
                      'Total Rentals',
                  value:
                      '$completedRentals',
                  icon:
                      Icons.repeat,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _PerformanceCard(
                  title:
                      'Revenue',
                  value:
                      'Rs. ${_formatPrice(totalRevenue)}',
                  icon: Icons
                      .payments_outlined,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _PerformanceCard(
                  title:
                      'Active Rentals',
                  value:
                      '$activeRentals',
                  icon:
                      Icons.swap_horiz,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ===============================================
          // TOTAL REVENUE
          // ===============================================
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color:
                    const Color(
                  0xFFE5E5E5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Total Revenue Generated',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  'Rs. ${_formatPrice(totalRevenue)}',
                  style:
                      const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                const Text(
                  'Based on completed rentals',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorScreen(
    String message,
  ) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  static String _formatPrice(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }
}

// =========================================================
// EQUIPMENT STATS MODEL
// =========================================================
class _EquipmentStats {
  final String equipmentId;
  final String name;

  int rentals;
  double revenue;

  _EquipmentStats({
    required this.equipmentId,
    required this.name,
    this.rentals = 0,
    this.revenue = 0,
  });
}

// =========================================================
// LEGEND ROW
// =========================================================
class _LegendRow
    extends StatelessWidget {
  final int index;
  final String name;
  final int rentals;
  final double revenue;

  const _LegendRow({
    required this.index,
    required this.name,
    required this.rentals,
    required this.revenue,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors = [
      const Color(
        0xFFED1235,
      ),
      const Color(
        0xFFFF8A00,
      ),
      const Color(
        0xFF2E8B3C,
      ),
    ];

    final color =
        colors[index %
            colors.length];

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Text(
            name,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '$rentals Rentals',
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.grey,
              ),
            ),
            Text(
              'Rs. ${_formatPrice(revenue)}',
              style:
                  const TextStyle(
                fontSize: 10,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatPrice(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }
}

// =========================================================
// PERFORMANCE CARD
// =========================================================
class _PerformanceCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _PerformanceCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 115,
      ),
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFE5E5E5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color:
                EquipmentPerformanceScreen
                    .primaryRed,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Colors.grey,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment:
                Alignment.centerLeft,
            child: Text(
              value,
              style:
                  const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// DONUT CHART
// =========================================================
class _RentalDonutPainter
    extends CustomPainter {
  final List<_EquipmentStats>
      equipment;

  _RentalDonutPainter({
    required this.equipment,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        math.min(
              size.width,
              size.height,
            ) /
            2 -
            18;

    final backgroundPaint =
        Paint()
          ..color =
              const Color(
            0xFFEDEDED,
          )
          ..style =
              PaintingStyle
                  .stroke
          ..strokeWidth = 20;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    if (equipment.isEmpty) {
      return;
    }

    final int totalRentals =
        equipment.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum +
          item.rentals,
    );

    if (totalRentals == 0) {
      return;
    }

    final colors = [
      const Color(
        0xFFED1235,
      ),
      const Color(
        0xFFFF8A00,
      ),
      const Color(
        0xFF2E8B3C,
      ),
    ];

    double startAngle =
        -math.pi / 2;

    for (int i = 0;
        i < equipment.length;
        i++) {
      final item =
          equipment[i];

      final double sweepAngle =
          (item.rentals /
                  totalRentals) *
              math.pi *
              2;

      final paint = Paint()
        ..color = colors[
            i % colors.length]
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap =
            StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle +=
          sweepAngle;
    }
  }

  @override
  bool shouldRepaint(
    covariant _RentalDonutPainter
        oldDelegate,
  ) {
    return true;
  }
}