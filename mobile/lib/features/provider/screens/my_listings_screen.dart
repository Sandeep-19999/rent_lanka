import '../widgets/provider_bottom_navigation.dart';
// // import 'package:flutter/material.dart';
// // import 'add_equipment_screen.dart';
// // import 'listing_details_screen.dart';

// // class MyListingsScreen extends StatelessWidget {
// //   const MyListingsScreen({super.key});

// //   static const Color primaryRed = Color(0xFFED1235);
// //   static const Color backgroundColor = Color(0xFFF8F8FA);
// //   static const Color textGrey = Color(0xFF8A8A8A);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: backgroundColor,

// //       body: SafeArea(
// //         child: Center(
// //           child: ConstrainedBox(
// //             constraints: const BoxConstraints(maxWidth: 420),
// //             child: Padding(
// //               padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Header
// //                   Row(
// //                     children: [
// //                       IconButton(
// //                         onPressed: () {
// //                           Navigator.pop(context);
// //                         },
// //                         padding: EdgeInsets.zero,
// //                         constraints: const BoxConstraints(),
// //                         icon: const Icon(
// //                           Icons.arrow_back_ios_new,
// //                           size: 22,
// //                         ),
// //                       ),

// //                       const SizedBox(width: 14),

// //                       const Expanded(
// //                         child: Text(
// //                           'My Equipment',
// //                           style: TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.w700,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                       ),

// //                       SizedBox(
// //                         height: 38,
// //                         child: ElevatedButton.icon(
// //                           onPressed: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     const AddEquipmentScreen(),
// //                               ),
// //                             );
// //                           },
// //                           icon: const Icon(
// //                             Icons.add,
// //                             size: 17,
// //                           ),
// //                           label: const Text(
// //                             'Add New',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.w700,
// //                               fontSize: 13,
// //                             ),
// //                           ),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: primaryRed,
// //                             foregroundColor: Colors.white,
// //                             elevation: 0,
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 14,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(22),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 26),

// //                   // Equipment list
// //                   Expanded(
// //                     child: ListView(
// //                       children: [
// //                         _equipmentCard(
// //                           context: context,
// //                           icon: Icons.sports_cricket,
// //                           name: 'SS Cricket Bat',
// //                           price: 'Rs. 1,200 / day',
// //                           status: 'Available',
// //                           statusColor: const Color(0xFF3EAF5B),
// //                           statusBackground: const Color(0xFFE8F7EC),
// //                         ),

// //                         const SizedBox(height: 14),

// //                         _equipmentCard(
// //                           context: context,
// //                           icon: Icons.sports_tennis,
// //                           name: 'Yonex Racket',
// //                           price: 'Rs. 800 / day',
// //                           status: 'Rented',
// //                           statusColor: Colors.orange,
// //                           statusBackground: const Color(0xFFFFF1DE),
// //                         ),

// //                         const SizedBox(height: 14),

// //                         _equipmentCard(
// //                           context: context,
// //                           icon: Icons.sports_cricket_outlined,
// //                           name: 'Cricket Gloves',
// //                           price: 'Rs. 900 / day',
// //                           status: 'Excellent',
// //                           statusColor: const Color(0xFF555555),
// //                           statusBackground: const Color(0xFFF0F0F2),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),

// //       bottomNavigationBar: _buildBottomNavigation(context),
// //     );
// //   }

// //   Widget _equipmentCard({
// //     required BuildContext context,
// //     required IconData icon,
// //     required String name,
// //     required String price,
// //     required String status,
// //     required Color statusColor,
// //     required Color statusBackground,
// //   }) {
// //     return Material(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(16),
// //       child: InkWell(
// //         borderRadius: BorderRadius.circular(16),
// //         onTap: () {
// //   Navigator.push(
// //     context,
// //     MaterialPageRoute(
// //       builder: (context) => const ListingDetailsScreen(),
// //     ),
// //   );
// // },
// //         child: Container(
// //           padding: const EdgeInsets.all(15),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(
// //               color: const Color(0xFFE5E5E5),
// //             ),
// //           ),
// //           child: Row(
// //             children: [
// //               // Equipment image placeholder
// //               Container(
// //                 width: 82,
// //                 height: 72,
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF7F7F8),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Icon(
// //                   icon,
// //                   size: 48,
// //                   color: const Color(0xFF555555),
// //                 ),
// //               ),

// //               const SizedBox(width: 16),

// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       name,
// //                       style: const TextStyle(
// //                         fontSize: 17,
// //                         fontWeight: FontWeight.w700,
// //                       ),
// //                     ),

// //                     const SizedBox(height: 5),

// //                     Text(
// //                       price,
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         color: textGrey,
// //                       ),
// //                     ),

// //                     const SizedBox(height: 7),

// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 4,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: statusBackground,
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Text(
// //                         status,
// //                         style: TextStyle(
// //                           color: statusColor,
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w700,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               const Icon(
// //                 Icons.chevron_right,
// //                 color: Color(0xFFAAAAAA),
// //                 size: 25,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildBottomNavigation(BuildContext context) {
// //     return Container(
// //       height: 75,
// //       decoration: const BoxDecoration(
// //         color: Colors.white,
// //         border: Border(
// //           top: BorderSide(
// //             color: Color(0xFFE8E8E8),
// //           ),
// //         ),
// //       ),
// //       child: Center(
// //         child: SizedBox(
// //           width: 420,
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: [
// //               _BottomNavItem(
// //                 icon: Icons.grid_view_rounded,
// //                 label: 'Dashboard',
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                 },
// //               ),

// //               const _BottomNavItem(
// //                 icon: Icons.hexagon_outlined,
// //                 label: 'My Items',
// //                 active: true,
// //               ),

// //               const _BottomNavItem(
// //                 icon: Icons.shopping_bag_outlined,
// //                 label: 'Requests',
// //               ),

// //               const _BottomNavItem(
// //                 icon: Icons.chat_bubble_outline,
// //                 label: 'Messages',
// //               ),

// //               const _BottomNavItem(
// //                 icon: Icons.person_outline,
// //                 label: 'Profile',
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _BottomNavItem extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final bool active;
// //   final VoidCallback? onTap;

// //   const _BottomNavItem({
// //     required this.icon,
// //     required this.label,
// //     this.active = false,
// //     this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     const red = Color(0xFFED1235);

// //     return InkWell(
// //       onTap: onTap,
// //       child: SizedBox(
// //         width: 65,
// //         height: 65,
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               icon,
// //               size: 24,
// //               color: active ? red : Colors.grey,
// //             ),
// //             const SizedBox(height: 5),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 9,
// //                 color: active ? red : Colors.grey,
// //                 fontWeight:
// //                     active ? FontWeight.w700 : FontWeight.w400,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import 'add_equipment_screen.dart';
// import 'listing_details_screen.dart';

// class MyListingsScreen extends StatelessWidget {
//   const MyListingsScreen({super.key});

//   static const Color primaryRed = Color(0xFFED1235);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Column(
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(
//                     20,
//                     18,
//                     20,
//                     15,
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         icon: const Icon(
//                           Icons.arrow_back_ios_new,
//                           size: 22,
//                         ),
//                       ),

//                       const SizedBox(width: 14),

//                       const Expanded(
//                         child: Text(
//                           'My Equipment',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),

//                       ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   const AddEquipmentScreen(),
//                             ),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.add,
//                           size: 18,
//                         ),
//                         label: const Text(
//                           'Add New',
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryRed,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(20),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Divider(
//                   height: 1,
//                   color: Color(0xFFEAEAEA),
//                 ),

//                 // Firestore data
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('equipment')
//                         .where(
//                           'providerId',
//                           isEqualTo: 'demo_provider',
//                         )
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Text(
//                               'Something went wrong:\n${snapshot.error}',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         );
//                       }

//                       if (snapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return const Center(
//                           child: CircularProgressIndicator(
//                             color: primaryRed,
//                           ),
//                         );
//                       }

//                       final documents =
//                           snapshot.data?.docs ?? [];

//                       if (documents.isEmpty) {
//                         return _buildEmptyState(context);
//                       }

//                       return ListView.separated(
//                         padding: const EdgeInsets.fromLTRB(
//                           20,
//                           22,
//                           20,
//                           25,
//                         ),
//                         itemCount: documents.length,
//                         separatorBuilder: (context, index) {
//                           return const SizedBox(height: 14);
//                         },
//                         itemBuilder: (context, index) {
//                           final document = documents[index];

//                           final data = document.data()
//                               as Map<String, dynamic>;

//                           final name =
//                               data['name']?.toString() ??
//                                   'Equipment';

//                           final category =
//                               data['category']?.toString() ??
//                                   '';

//                           final condition =
//                               data['condition']?.toString() ??
//                                   '';

//                           final status =
//                               data['status']?.toString() ??
//                                   'Available';

//                           final priceValue =
//                               data['pricePerDay'];

//                           final double price =
//                               priceValue is num
//                                   ? priceValue.toDouble()
//                                   : 0;

//                           return _equipmentCard(
//   context: context,
//   equipmentId: document.id,
//   name: name,
//   category: category,
//   condition: condition,
//   status: status,
//   price: price,
// );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigation(context),
//     );
//   }

//   Widget _equipmentCard({
//     required BuildContext context,
//     required String name,
//     required String category,
//     required String condition,
//     required String status,
//     required double price,
//   }) {
//     final bool available =
//         status.toLowerCase() == 'available';

//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 const ListingDetailsScreen(),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFFE1E1E1),
//           ),
//         ),
//         child: Row(
//           children: [
//             // Equipment icon
//             Container(
//               width: 65,
//               height: 65,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 _getCategoryIcon(category),
//                 size: 32,
//                 color: Colors.black87,
//               ),
//             ),

//             const SizedBox(width: 14),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 5),

//                   Text(
//                     [
//                       if (category.isNotEmpty) category,
//                       if (condition.isNotEmpty) condition,
//                     ].join(' • '),
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     'Rs. ${_formatPrice(price)}/day',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: primaryRed,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(width: 10),

//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: available
//                         ? const Color(0xFFEAF8EF)
//                         : const Color(0xFFFFEEF1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: available
//                           ? const Color(0xFF27944A)
//                           : primaryRed,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 14,
//                   color: Colors.grey,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.sports_cricket_outlined,
//               size: 65,
//               color: Colors.grey,
//             ),

//             const SizedBox(height: 18),

//             const Text(
//               'No equipment yet',
//               style: TextStyle(
//                 fontSize: 19,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'Add your first equipment listing to start renting.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),

//             const SizedBox(height: 20),

//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         const AddEquipmentScreen(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Add Equipment'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryRed,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatPrice(double price) {
//     if (price == price.roundToDouble()) {
//       return price.toInt().toString();
//     }

//     return price.toStringAsFixed(2);
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'cricket':
//         return Icons.sports_cricket;

//       case 'football':
//         return Icons.sports_soccer;

//       case 'tennis':
//         return Icons.sports_tennis;

//       case 'cycling':
//         return Icons.pedal_bike;

//       case 'volleyball':
//         return Icons.sports_volleyball;

//       case 'hockey':
//         return Icons.sports_hockey;

//       default:
//         return Icons.sports;
//     }
//   }

//   Widget _buildBottomNavigation(
//     BuildContext context,
//   ) {
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
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,
//             children: [
//               _BottomNavItem(
//                 icon: Icons.grid_view_rounded,
//                 label: 'Dashboard',
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),

//               const _BottomNavItem(
//                 icon: Icons.hexagon_outlined,
//                 label: 'My Items',
//                 active: true,
//               ),

//               const _BottomNavItem(
//                 icon: Icons.shopping_bag_outlined,
//                 label: 'Requests',
//               ),

//               const _BottomNavItem(
//                 icon: Icons.chat_bubble_outline,
//                 label: 'Messages',
//               ),

//               const _BottomNavItem(
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
//     const Color red = Color(0xFFED1235);

//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         width: 65,
//         height: 65,
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: active
//                   ? red
//                   : Colors.grey,
//             ),

//             const SizedBox(height: 5),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 9,
//                 color: active
//                     ? red
//                     : Colors.grey,
//                 fontWeight: active
//                     ? FontWeight.w700
//                     : FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../models/equipment_model.dart';
import '../services/equipment_service.dart';

import 'add_equipment_screen.dart';
import 'listing_details_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static final EquipmentService _equipmentService =
      EquipmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    15,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          'My Equipment',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddEquipmentScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                        ),
                        label: const Text(
                          'Add New',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEAEA),
                ),

                // Equipment List
                Expanded(
                  child: StreamBuilder<
                      List<EquipmentModel>>(
                    stream:
                        _equipmentService.watchMyEquipment(),
                    builder: (context, snapshot) {
                      // Error
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(20),
                            child: Text(
                              'Something went wrong:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      }

                      // Loading
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

                      final equipmentList =
                          snapshot.data ?? [];

                      // Empty
                      if (equipmentList.isEmpty) {
                        return _buildEmptyState(
                          context,
                        );
                      }

                      // Equipment list
                      return ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          22,
                          20,
                          25,
                        ),
                        itemCount: equipmentList.length,
                        separatorBuilder:
                            (context, index) {
                          return const SizedBox(
                            height: 14,
                          );
                        },
                        itemBuilder:
                            (context, index) {
                          final equipment =
                              equipmentList[index];

                          return _equipmentCard(
                            context: context,
                            equipmentId:
                                equipment.id,
                            name: equipment.name,
                            category:
                                equipment.category,
                            condition:
                                equipment.condition,
                            status: equipment.status,
                            price:
                                equipment.pricePerDay,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  // Equipment Card
  Widget _equipmentCard({
    required BuildContext context,
    required String equipmentId,
    required String name,
    required String category,
    required String condition,
    required String status,
    required double price,
  }) {
    final bool available =
        status.toLowerCase() == 'available';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ListingDetailsScreen(
              equipmentId: equipmentId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE1E1E1),
          ),
        ),
        child: Row(
          children: [
            // Equipment icon
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category),
                size: 32,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 14),

            // Equipment information
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    [
                      if (category.isNotEmpty)
                        category,
                      if (condition.isNotEmpty)
                        condition,
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Rs. ${_formatPrice(price)}/day',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primaryRed,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Status
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: available
                        ? const Color(0xFFEAF8EF)
                        : const Color(0xFFFFEEF1),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: available
                          ? const Color(
                              0xFF27944A,
                            )
                          : primaryRed,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_cricket_outlined,
              size: 65,
              color: Colors.grey,
            ),

            const SizedBox(height: 18),

            const Text(
              'No equipment yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your first equipment listing to start renting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AddEquipmentScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Add Equipment',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Price formatter
  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }

  // Category icon
  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;

      case 'football':
        return Icons.sports_soccer;

      case 'tennis':
        return Icons.sports_tennis;

      case 'cycling':
        return Icons.pedal_bike;

      case 'volleyball':
        return Icons.sports_volleyball;

      case 'hockey':
        return Icons.sports_hockey;

      default:
        return Icons.sports;
    }
  }

  // Bottom Navigation
  Widget _buildBottomNavigation(BuildContext context) =>
      const ProviderBottomNavigation(currentIndex: 1);
}

// Bottom Navigation Item
