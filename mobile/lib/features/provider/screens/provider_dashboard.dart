import '../widgets/provider_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/provider_dashboard_model.dart';
import '../services/provider_dashboard_service.dart';

import 'add_equipment_screen.dart';
import 'equipment_performance_screen.dart';
import 'my_listings_screen.dart';
import 'rental_requests_screen.dart';
import 'withdraw_funds_screen.dart';
import 'withdrawal_history_screen.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({
    super.key,
  });

  static const Color primaryRed =
      Color(0xFFED1235);

  static final ProviderDashboardService
      _dashboardService =
      ProviderDashboardService();

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
                ProviderDashboardModel>(
              stream: _dashboardService
                  .watchDashboard(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.hasError) {
                  return _errorScreen(
                    'Failed to load provider dashboard.',
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

                final dashboard =
                    snapshot.data!;

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    20,
                    20,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // =========================
                      // HEADER
                      // =========================

                      _buildHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      // =========================
                      // EARNINGS
                      // =========================

                      _buildEarningsCard(
                        context: context,
                        totalEarnings:
                            dashboard
                                .totalEarnings,
                        availableToWithdraw:
                            dashboard
                                .availableToWithdraw,
                        withdrawalTotal:
                            dashboard
                                .withdrawalTotal,
                        completedCount:
                            dashboard
                                .completedCount,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // QUICK ACTIONS
                      // =========================

                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _QuickAction(
                              icon: Icons
                                  .add_circle_outline,
                              label:
                                  'Add Item',
                              onTap: () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                      context,
                                    ) =>
                                            const AddEquipmentScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _QuickAction(
                              icon: Icons
                                  .account_balance_wallet_outlined,
                              label:
                                  'Withdraw',
                              onTap: () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                      context,
                                    ) =>
                                            const WithdrawFundsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _QuickAction(
                              icon: Icons
                                  .insights_outlined,
                              label:
                                  'Insights',
                              onTap: () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                      context,
                                    ) =>
                                            const EquipmentPerformanceScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _QuickAction(
                              icon:
                                  Icons.history,
                              label:
                                  'History',
                              onTap: () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                      context,
                                    ) =>
                                            const WithdrawalHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // OVERVIEW
                      // =========================

                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'My Equipment',
                              value:
                                  '${dashboard.equipmentCount}',
                              icon: Icons
                                  .inventory_2_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Pending Requests',
                              value:
                                  '${dashboard.pendingCount}',
                              icon: Icons
                                  .pending_actions,
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
                                _StatCard(
                              title:
                                  'Active Rentals',
                              value:
                                  '${dashboard.activeCount}',
                              icon: Icons
                                  .swap_horiz,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _StatCard(
                              title:
                                  'Completed',
                              value:
                                  '${dashboard.completedCount}',
                              icon: Icons
                                  .check_circle_outline,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // MANAGEMENT
                      // =========================

                      const Text(
                        'Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _ManagementCard(
                        icon: Icons
                            .shopping_bag_outlined,
                        title:
                            'Rental Requests',
                        subtitle:
                            '${dashboard.pendingCount} pending • '
                            '${dashboard.acceptedCount} accepted',
                        badgeText:
                            '${dashboard.pendingCount}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                context,
                              ) =>
                                      const RentalRequestsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _ManagementCard(
                        icon:
                            Icons.sports_cricket,
                        title:
                            'My Equipment',
                        subtitle:
                            '${dashboard.equipmentCount} equipment listings',
                        badgeText:
                            '${dashboard.equipmentCount}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                context,
                              ) =>
                                      const MyListingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _ManagementCard(
                        icon:
                            Icons.swap_horiz,
                        title:
                            'Active Rentals',
                        subtitle:
                            '${dashboard.activeCount} rentals currently active',
                        badgeText:
                            '${dashboard.activeCount}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                context,
                              ) =>
                                      const RentalRequestsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================
                      // FINANCIAL SUMMARY
                      // =========================

                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _SummaryRow(
                        label:
                            'Total earnings',
                        value:
                            'Rs. ${_formatPrice(dashboard.totalEarnings)}',
                        highlight: true,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _SummaryRow(
                        label:
                            'Withdrawal requests',
                        value:
                            'Rs. ${_formatPrice(dashboard.withdrawalTotal)}',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _SummaryRow(
                        label:
                            'Available to withdraw',
                        value:
                            'Rs. ${_formatPrice(dashboard.availableToWithdraw)}',
                        highlight: true,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _SummaryRow(
                        label:
                            'Completed rentals',
                        value:
                            '${dashboard.completedCount}',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _SummaryRow(
                        label:
                            'Active rentals',
                        value:
                            '${dashboard.activeCount}',
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(
        context,
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    final authName = user?.displayName?.trim() ?? '';
    final fallbackName = authName.isNotEmpty ? authName : 'Provider';

    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor:
              Color(
            0xFFE8E8E8,
          ),
          child: Icon(
            Icons.person,
            color:
                Colors.black54,
            size: 28,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: user == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.data()?['name']
                          ?.toString().trim() ??
                      '';
                  return Text(
                    name.isNotEmpty ? name : fallbackName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            _showComingSoon(
              context,
              'Notifications',
            );
          },
          icon: const Icon(
            Icons
                .notifications_none_rounded,
            size: 27,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EARNINGS CARD
  // =========================================================

  Widget _buildEarningsCard({
    required BuildContext context,
    required double totalEarnings,
    required double availableToWithdraw,
    required double withdrawalTotal,
    required int completedCount,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFFED1235,
            ),
            Color(
              0xFFFF3653,
            ),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(
              color:
                  Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            'Rs. ${_formatPrice(totalEarnings)}',
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .all(
              14,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.15,
              ),
              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Available to withdraw',
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize:
                              12,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        'Rs. ${_formatPrice(availableToWithdraw)}',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize:
                              20,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                          context,
                        ) =>
                                const WithdrawFundsScreen(),
                      ),
                    );
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor:
                        primaryRed,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'Withdraw',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Completed rentals: $completedCount',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),

              Text(
                'Withdrawals: Rs. ${_formatPrice(withdrawalTotal)}',
                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

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

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigation(BuildContext context) =>
      const ProviderBottomNavigation(currentIndex: 0);

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

  static void _showComingSoon(
    BuildContext context,
    String screenName,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$screenName will be connected later.',
        ),
      ),
    );
  }
}

// ===========================================================
// QUICK ACTION
// ===========================================================

class _QuickAction
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 15,
          horizontal: 4,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
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
            Icon(
              icon,
              color:
                  ProviderDashboard
                      .primaryRed,
              size: 25,
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow
                      .ellipsis,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// STAT CARD
// ===========================================================

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
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
            color:
                ProviderDashboard
                    .primaryRed,
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// MANAGEMENT CARD
// ===========================================================

class _ManagementCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
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
              child: Icon(
                icon,
                color:
                    ProviderDashboard
                        .primaryRed,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              constraints:
                  const BoxConstraints(
                minWidth: 27,
                minHeight: 27,
              ),
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              alignment:
                  Alignment.center,
              decoration:
                  const BoxDecoration(
                color:
                    ProviderDashboard
                        .primaryRed,
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
              ),
              child: Text(
                badgeText,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Icon(
              Icons
                  .arrow_forward_ios,
              size: 15,
              color:
                  Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// SUMMARY ROW
// ===========================================================

class _SummaryRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFE8E8E8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    Colors.grey,
              ),
            ),
          ),

          Text(
            value,
            style:
                TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color: highlight
                  ? ProviderDashboard
                      .primaryRed
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// BOTTOM NAVIGATION ITEM
// ===========================================================
