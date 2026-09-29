// import 'package:flutter/material.dart';

// import 'add_equipment_screen.dart';
// import 'my_listings_screen.dart';
// import 'rental_requests_screen.dart';

// class ProviderDashboard extends StatelessWidget {
//   const ProviderDashboard({super.key});

//   static const Color primaryRed = Color(0xFFED1235);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F8FA),

//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     children: [
//                       const CircleAvatar(
//                         radius: 24,
//                         backgroundColor: Color(0xFFE8E8E8),
//                         child: Icon(
//                           Icons.person,
//                           color: Colors.black54,
//                           size: 28,
//                         ),
//                       ),

//                       const SizedBox(width: 12),

//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Welcome back,',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(height: 3),
//                             Text(
//                               'Kamal',
//                               style: TextStyle(
//                                 fontSize: 21,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       IconButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                 'Notifications will be connected later.',
//                               ),
//                             ),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.notifications_none_rounded,
//                           size: 27,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 25),

//                   // Earnings Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFFED1235),
//                           Color(0xFFFF3653),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Total Earnings',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),

//                         const SizedBox(height: 7),

//                         const Text(
//                           'Rs. 34,500',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 30,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Available to withdraw',
//                                   style: TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 SizedBox(height: 3),
//                                 Text(
//                                   'Rs. 21,000',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             ElevatedButton(
//                               onPressed: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       'Withdraw screen will be connected later.',
//                                     ),
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: primaryRed,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Withdraw',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 28),

//                   const Text(
//                     'Quick Actions',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   // Quick Actions
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _QuickAction(
//                           icon: Icons.add_circle_outline,
//                           label: 'Add Item',
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     const AddEquipmentScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: _QuickAction(
//                           icon: Icons.account_balance_wallet_outlined,
//                           label: 'Withdraw',
//                           onTap: () {
//                             _showComingSoon(
//                               context,
//                               'Withdraw',
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: _QuickAction(
//                           icon: Icons.bar_chart_rounded,
//                           label: 'Insights',
//                           onTap: () {
//                             _showComingSoon(
//                               context,
//                               'Insights',
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: _QuickAction(
//                           icon: Icons.history,
//                           label: 'History',
//                           onTap: () {
//                             _showComingSoon(
//                               context,
//                               'History',
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 28),

//                   const Text(
//                     'Management',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   // Rental Requests
//                   _ManagementCard(
//                     icon: Icons.shopping_bag_outlined,
//                     title: 'Rental Requests',
//                     subtitle: 'View and manage rental requests',
//                     badgeText: '3',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const RentalRequestsScreen(),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 12),

//                   // My Equipment
//                   _ManagementCard(
//                     icon: Icons.sports_cricket,
//                     title: 'My Equipment',
//                     subtitle: 'Manage your equipment listings',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const MyListingsScreen(),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 28),

//                   const Text(
//                     'Recent Activity',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   _ActivityCard(
//                     icon: Icons.check_circle_outline,
//                     title: 'Rental completed',
//                     subtitle: 'SS Cricket Bat',
//                     value: '+ Rs. 7,980',
//                   ),

//                   const SizedBox(height: 10),

//                   _ActivityCard(
//                     icon: Icons.shopping_bag_outlined,
//                     title: 'New rental request',
//                     subtitle: 'Yonex Racket',
//                     value: 'Pending',
//                   ),

//                   const SizedBox(height: 28),

//                   const Text(
//                     'Top Earning Items',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   _EquipmentCard(
//                     icon: Icons.sports_cricket,
//                     title: 'SS Cricket Bat',
//                     subtitle: '8 rentals',
//                     value: 'Rs. 9,600',
//                   ),

//                   const SizedBox(height: 10),

//                   _EquipmentCard(
//                     icon: Icons.sports_tennis,
//                     title: 'Yonex Racket',
//                     subtitle: '6 rentals',
//                     value: 'Rs. 4,800',
//                   ),

//                   const SizedBox(height: 15),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigation(context),
//     );
//   }

//   // Bottom Navigation
//   Widget _buildBottomNavigation(BuildContext context) {
//     return Container(
//       height: 75,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(
//             color: Color(0xFFE8E8E8),
//           ),
//         ),
//       ),
//       child: Center(
//         child: SizedBox(
//           width: 420,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               const _BottomNavItem(
//                 icon: Icons.grid_view_rounded,
//                 label: 'Dashboard',
//                 active: true,
//               ),

//               // My Items
//               _BottomNavItem(
//                 icon: Icons.hexagon_outlined,
//                 label: 'My Items',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           const MyListingsScreen(),
//                     ),
//                   );
//                 },
//               ),

//               // Requests
//               _BottomNavItem(
//                 icon: Icons.shopping_bag_outlined,
//                 label: 'Requests',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           const RentalRequestsScreen(),
//                     ),
//                   );
//                 },
//               ),

//               _BottomNavItem(
//                 icon: Icons.chat_bubble_outline,
//                 label: 'Messages',
//                 onTap: () {
//                   _showComingSoon(
//                     context,
//                     'Messages',
//                   );
//                 },
//               ),

//               _BottomNavItem(
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//                 onTap: () {
//                   _showComingSoon(
//                     context,
//                     'Profile',
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   static void _showComingSoon(
//     BuildContext context,
//     String screenName,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           '$screenName will be connected later.',
//         ),
//       ),
//     );
//   }
// }

// // Quick Action Widget
// class _QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _QuickAction({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           vertical: 15,
//           horizontal: 5,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: const Color(0xFFE5E5E5),
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: ProviderDashboard.primaryRed,
//               size: 26,
//             ),
//             const SizedBox(height: 7),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Management Card
// class _ManagementCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String? badgeText;
//   final VoidCallback onTap;

//   const _ManagementCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//     this.badgeText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: const Color(0xFFE5E5E5),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFEEF1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: ProviderDashboard.primaryRed,
//               ),
//             ),

//             const SizedBox(width: 13),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             if (badgeText != null)
//               Container(
//                 width: 25,
//                 height: 25,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: ProviderDashboard.primaryRed,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   badgeText!,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),

//             const SizedBox(width: 8),

//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 15,
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Activity Card
// class _ActivityCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String value;

//   const _ActivityCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: const Color(0xFFE8E8E8),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: ProviderDashboard.primaryRed,
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Equipment Card
// class _EquipmentCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String value;

//   const _EquipmentCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: const Color(0xFFE8E8E8),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF4F4F4),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w800,
//               color: ProviderDashboard.primaryRed,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Bottom Navigation Item
// class _BottomNavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool active;
//   final VoidCallback? onTap;

//   const _BottomNavItem({
//     required this.icon,
//     required this.label,
//     this.active = false,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const red = Color(0xFFED1235);

//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         width: 67,
//         height: 65,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: active ? red : Colors.grey,
//             ),

//             const SizedBox(height: 5),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 9,
//                 color: active ? red : Colors.grey,
//                 fontWeight:
//                     active ? FontWeight.w700 : FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_equipment_screen.dart';
import 'my_listings_screen.dart';
import 'rental_requests_screen.dart';
import '../../services/auth_service.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

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
                    'Failed to load equipment.',
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
                    requestSnapshot,
                  ) {
                    if (requestSnapshot.hasError) {
                      return _errorScreen(
                        'Failed to load rental requests.',
                      );
                    }

                    if ((!equipmentSnapshot.hasData &&
                            equipmentSnapshot.connectionState ==
                                ConnectionState.waiting) ||
                        (!requestSnapshot.hasData &&
                            requestSnapshot.connectionState ==
                                ConnectionState.waiting)) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryRed,
                        ),
                      );
                    }

                    final equipmentDocuments =
                        equipmentSnapshot.data?.docs ?? [];

                    final requestDocuments =
                        requestSnapshot.data?.docs ?? [];

                    final int equipmentCount =
                        equipmentDocuments.length;

                    int pendingCount = 0;
                    int acceptedCount = 0;
                    int activeCount = 0;
                    int completedCount = 0;

                    double completedRentalValue = 0;

                    for (final document in requestDocuments) {
                      final data = document.data();

                      final String status =
                          data['status']
                                  ?.toString()
                                  .toLowerCase() ??
                              'pending';

                      switch (status) {
                        case 'pending':
                          pendingCount++;
                          break;

                        case 'accepted':
                          acceptedCount++;
                          break;

                        case 'active':
                          activeCount++;
                          break;

                        case 'completed':
                          completedCount++;

                          final amount =
                              data['totalAmount'];

                          if (amount is num) {
                            completedRentalValue +=
                                amount.toDouble();
                          }

                          break;
                      }
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),

                          const SizedBox(height: 25),

                          _buildSummaryCard(
                            context: context,
                            completedRentalValue:
                                completedRentalValue,
                            completedCount:
                                completedCount,
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon:
                                      Icons.add_circle_outline,
                                  label: 'Add Item',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddEquipmentScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _QuickAction(
                                  icon:
                                      Icons.inventory_2_outlined,
                                  label: 'My Items',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MyListingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _QuickAction(
                                  icon:
                                      Icons.shopping_bag_outlined,
                                  label: 'Requests',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RentalRequestsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.history,
                                  label: 'History',
                                  onTap: () {
                                    _showComingSoon(
                                      context,
                                      'History',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'My Equipment',
                                  value: '$equipmentCount',
                                  icon:
                                      Icons.inventory_2_outlined,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatCard(
                                  title: 'Pending Requests',
                                  value: '$pendingCount',
                                  icon: Icons.pending_actions,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Active Rentals',
                                  value: '$activeCount',
                                  icon: Icons.swap_horiz,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _StatCard(
                                  title: 'Completed',
                                  value: '$completedCount',
                                  icon:
                                      Icons.check_circle_outline,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _ManagementCard(
                            icon:
                                Icons.shopping_bag_outlined,
                            title: 'Rental Requests',
                            subtitle:
                                '$pendingCount pending • $acceptedCount accepted',
                            badgeText: '$pendingCount',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RentalRequestsScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _ManagementCard(
                            icon: Icons.sports_cricket,
                            title: 'My Equipment',
                            subtitle:
                                '$equipmentCount equipment listings',
                            badgeText:
                                '$equipmentCount',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MyListingsScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _ManagementCard(
                            icon: Icons.swap_horiz,
                            title: 'Active Rentals',
                            subtitle:
                                '$activeCount rentals currently active',
                            badgeText: '$activeCount',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RentalRequestsScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Rental Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _SummaryRow(
                            label: 'Accepted requests',
                            value: '$acceptedCount',
                          ),

                          const SizedBox(height: 10),

                          _SummaryRow(
                            label: 'Active rentals',
                            value: '$activeCount',
                          ),

                          const SizedBox(height: 10),

                          _SummaryRow(
                            label: 'Completed rentals',
                            value: '$completedCount',
                          ),

                          const SizedBox(height: 10),

                          _SummaryRow(
                            label:
                                'Completed rental value',
                            value:
                                'Rs. ${_formatPrice(completedRentalValue)}',
                            highlight: true,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor:
              Color(0xFFE8E8E8),
          child: Icon(
            Icons.person,
            color: Colors.black54,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Kamal',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
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
            Icons.notifications_none_rounded,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required double completedRentalValue,
    required int completedCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFED1235),
            Color(0xFFFF3653),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Completed Rental Value',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Rs. ${_formatPrice(completedRentalValue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completed rentals',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '$completedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RentalRequestsScreen(),
                    ),
                  );
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      primaryRed,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
                child: const Text(
                  'View Rentals',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
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

  Widget _buildBottomNavigation(
    BuildContext context,
  ) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8E8E8),
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 420,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              const _BottomNavItem(
                icon:
                    Icons.grid_view_rounded,
                label: 'Dashboard',
                active: true,
              ),

              _BottomNavItem(
                icon:
                    Icons.hexagon_outlined,
                label: 'My Items',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyListingsScreen(),
                    ),
                  );
                },
              ),

              _BottomNavItem(
                icon:
                    Icons.shopping_bag_outlined,
                label: 'Requests',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RentalRequestsScreen(),
                    ),
                  );
                },
              ),

              _BottomNavItem(
                icon:
                    Icons.chat_bubble_outline,
                label: 'Messages',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Messages',
                  );
                },
              ),

              _BottomNavItem(
                icon:
                    Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Profile',
                  );
                },
              ),
            ],
          ),
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

    return value.toStringAsFixed(2);
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
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
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
              color: ProviderDashboard
                  .primaryRed,
              size: 26,
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              label,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
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
            color: ProviderDashboard
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
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

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
          BorderRadius.circular(15),
      child: Container(
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
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
                color: const Color(
                  0xFFFFEEF1,
                ),
                borderRadius:
                    BorderRadius.circular(
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

            // Fixed version:
            // Container does not have a direct minWidth parameter.
            Container(
              constraints:
                  const BoxConstraints(
                minWidth: 27,
                minHeight: 27,
              ),
              padding:
                  const EdgeInsets.symmetric(
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
                  Radius.circular(20),
                ),
              ),
              child: Text(
                badgeText,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

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
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
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
                color: Colors.grey,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
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

class _BottomNavItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color red =
        Color(0xFFED1235);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 67,
        height: 65,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active
                  ? red
                  : Colors.grey,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active
                    ? red
                    : Colors.grey,
                fontWeight: active
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}