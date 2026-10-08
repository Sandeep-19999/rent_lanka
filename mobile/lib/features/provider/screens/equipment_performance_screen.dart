import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/equipment_performance_model.dart';
import '../services/equipment_performance_service.dart';

class EquipmentPerformanceScreen
    extends StatelessWidget {
  const EquipmentPerformanceScreen({
    super.key,
  });

  static const Color primaryRed =
      Color(0xFFED1235);

  static final EquipmentPerformanceService
      _performanceService =
      EquipmentPerformanceService();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F8FA),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: StreamBuilder<
                EquipmentPerformanceModel>(
              stream: _performanceService
                  .watchPerformance(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return _errorScreen(
                    'Failed to load equipment performance.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  );
                }

                final performance =
                    snapshot.data!;

                return _buildContent(
                  context: context,
                  performance:
                      performance,
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
    required EquipmentPerformanceModel
        performance,
  }) {
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
          // =========================
          // HEADER
          // =========================

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

          // =========================
          // PERFORMANCE CHART
          // =========================

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
                20,
              ),
              border: Border.all(
                color:
                    const Color(
                  0xFFE5E5E5,
                ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child:
                      CustomPaint(
                    painter:
                        _RentalDonutPainter(
                      equipment:
                          performance
                              .topEquipment,
                    ),
                    child:
                        Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Text(
                            'Total Rentals',
                            style:
                                TextStyle(
                              fontSize:
                                  12,
                              color:
                                  Colors.grey,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            '${performance.completedRentals}',
                            style:
                                const TextStyle(
                              fontSize:
                                  27,
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

                if (performance
                    .topEquipment
                    .isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.all(
                      15,
                    ),
                    child: Text(
                      'No completed rental data yet.',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    performance
                        .topEquipment
                        .length,
                    (
                      index,
                    ) {
                      final item =
                          performance
                                  .topEquipment[
                              index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),
                        child:
                            _LegendRow(
                          index: index,
                          item: item,
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

          // =========================
          // STAT CARDS
          // =========================

          Row(
            children: [
              Expanded(
                child:
                    _PerformanceCard(
                  title:
                      'Listed Equipment',
                  value:
                      '${performance.equipmentCount}',
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
                      '${performance.completedRentals}',
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
                      'Rs. ${_formatPrice(performance.totalRevenue)}',
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
                      '${performance.activeRentals}',
                  icon:
                      Icons.swap_horiz,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // =========================
          // TOTAL REVENUE
          // =========================

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
                  CrossAxisAlignment.start,
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
                  'Rs. ${_formatPrice(performance.totalRevenue)}',
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
        style:
            const TextStyle(
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
// LEGEND ROW
// =========================================================

class _LegendRow
    extends StatelessWidget {
  final int index;

  final EquipmentPerformanceItem item;

  const _LegendRow({
    required this.index,
    required this.item,
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

    final Color color =
        colors[
            index %
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
            item.name,
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
              '${item.rentals} Rentals',
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.grey,
              ),
            ),

            Text(
              'Rs. ${_formatPrice(item.revenue)}',
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
            fit:
                BoxFit.scaleDown,
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
  final List<
          EquipmentPerformanceItem>
      equipment;

  _RentalDonutPainter({
    required this.equipment,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Offset center =
        Offset(
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

    final Paint backgroundPaint =
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
        total,
        item,
      ) =>
          total +
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

    for (int index = 0;
        index <
            equipment.length;
        index++) {
      final item =
          equipment[index];

      final double sweepAngle =
          (item.rentals /
                  totalRentals) *
              math.pi *
              2;

      final Paint paint =
          Paint()
            ..color = colors[
                index %
                    colors.length]
            ..style =
                PaintingStyle
                    .stroke
            ..strokeWidth =
                20
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