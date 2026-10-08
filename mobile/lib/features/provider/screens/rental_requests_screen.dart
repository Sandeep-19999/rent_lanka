// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import 'request_details_screen.dart';

// class RentalRequestsScreen extends StatelessWidget {
//   const RentalRequestsScreen({super.key});

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
//                     18,
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

//                       const Text(
//                         'Rental Requests',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Divider(
//                   height: 1,
//                   color: Color(0xFFEAEAEA),
//                 ),

//                 // Firestore requests
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('rental_requests')
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
//                         return const _EmptyRequests();
//                       }

//                       return ListView.separated(
//                         padding: const EdgeInsets.all(20),
//                         itemCount: documents.length,
//                         separatorBuilder: (context, index) {
//                           return const SizedBox(height: 14);
//                         },
//                         itemBuilder: (context, index) {
//                           final document = documents[index];

//                           final data =
//                               document.data()
//                                   as Map<String, dynamic>;

//                           final playerName =
//                               data['playerName']?.toString() ??
//                                   'Player';

//                           final equipmentName =
//                               data['equipmentName']
//                                       ?.toString() ??
//                                   'Equipment';

//                           final startDate =
//                               data['startDate']?.toString() ??
//                                   '';

//                           final endDate =
//                               data['endDate']?.toString() ??
//                                   '';

//                           final status =
//                               data['status']?.toString() ??
//                                   'pending';

//                           final amountValue =
//                               data['totalAmount'];

//                           final double totalAmount =
//                               amountValue is num
//                                   ? amountValue.toDouble()
//                                   : 0;

//                           return _requestCard(
//                             context: context,

//                             // IMPORTANT
//                             requestId: document.id,

//                             playerName: playerName,
//                             equipmentName: equipmentName,
//                             startDate: startDate,
//                             endDate: endDate,
//                             totalAmount: totalAmount,
//                             status: status,
//                           );
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

//       bottomNavigationBar:
//           _buildBottomNavigation(context),
//     );
//   }

//   Widget _requestCard({
//     required BuildContext context,
//     required String requestId,
//     required String playerName,
//     required String equipmentName,
//     required String startDate,
//     required String endDate,
//     required double totalAmount,
//     required String status,
//   }) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 RequestDetailsScreen(
//               requestId: requestId,
//             ),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: const Color(0xFFDDDDDD),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Player
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Color(0xFFEAEAEA),
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.black54,
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Expanded(
//                     child: Text(
//                       playerName,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),

//                   _statusBadge(status),
//                 ],
//               ),
//             ),

//             const Divider(
//               height: 1,
//               color: Color(0xFFE5E5E5),
//             ),

//             // Request details
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text.rich(
//                     TextSpan(
//                       children: [
//                         const TextSpan(
//                           text: 'Requested: ',
//                           style: TextStyle(
//                             color: Colors.grey,
//                           ),
//                         ),
//                         TextSpan(
//                           text: equipmentName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     'Dates: $startDate - $endDate',
//                     style: const TextStyle(
//                       fontSize: 13,
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Rs. ${_formatPrice(totalAmount)}',
//                         style: const TextStyle(
//                           color: primaryRed,
//                           fontSize: 19,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),

//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 15,
//                         color: Colors.grey,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _statusBadge(String status) {
//     final normalizedStatus =
//         status.toLowerCase();

//     Color background;
//     Color textColor;

//     switch (normalizedStatus) {
//       case 'accepted':
//       case 'active':
//       case 'completed':
//         background = const Color(0xFFEAF8EF);
//         textColor = const Color(0xFF27944A);
//         break;

//       case 'rejected':
//         background = const Color(0xFFFFE8EC);
//         textColor = primaryRed;
//         break;

//       default:
//         background = const Color(0xFFFFF4DD);
//         textColor = const Color(0xFFC47A00);
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         normalizedStatus.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: textColor,
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
//               ),

//               const _BottomNavItem(
//                 icon: Icons.shopping_bag_outlined,
//                 label: 'Requests',
//                 active: true,
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

// class _EmptyRequests extends StatelessWidget {
//   const _EmptyRequests();

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_bag_outlined,
//             size: 60,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 15),
//           Text(
//             'No rental requests',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           SizedBox(height: 6),
//           Text(
//             'New requests will appear here.',
//             style: TextStyle(
//               color: Colors.grey,
//             ),
//           ),
//         ],
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
//               color:
//                   active ? red : Colors.grey,
//             ),
//             const SizedBox(height: 5),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 9,
//                 color:
//                     active ? red : Colors.grey,
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

import '../models/rental_request_model.dart';
import '../services/rental_request_service.dart';

import 'request_details_screen.dart';

class RentalRequestsScreen extends StatelessWidget {
  const RentalRequestsScreen({super.key});

  static const Color primaryRed = Color(0xFFED1235);

  static final RentalRequestService _requestService =
      RentalRequestService();

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
                    18,
                  ),
                  child: Row(
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

                      const SizedBox(width: 14),

                      const Text(
                        'Rental Requests',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEAEA),
                ),

                // Requests
                Expanded(
                  child: StreamBuilder<
                      List<RentalRequestModel>>(
                    stream: _requestService
                        .watchMyRentalRequests(),
                    builder: (
                      context,
                      snapshot,
                    ) {
                      // Error
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            child: Text(
                              'Something went wrong:\n${snapshot.error}',
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

                      final requests =
                          snapshot.data ?? [];

                      // Empty
                      if (requests.isEmpty) {
                        return const _EmptyRequests();
                      }

                      return ListView.separated(
                        padding:
                            const EdgeInsets.all(
                          20,
                        ),
                        itemCount: requests.length,
                        separatorBuilder:
                            (context, index) {
                          return const SizedBox(
                            height: 14,
                          );
                        },
                        itemBuilder:
                            (context, index) {
                          final request =
                              requests[index];

                          return _requestCard(
                            context: context,
                            request: request,
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

  // ===========================
  // REQUEST CARD
  // ===========================

  Widget _requestCard({
    required BuildContext context,
    required RentalRequestModel request,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RequestDetailsScreen(
              requestId: request.id,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFDDDDDD),
          ),
        ),
        child: Column(
          children: [
            // Player Information
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Color(0xFFEAEAEA),
                    child: Icon(
                      Icons.person,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      request.playerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),

                  _statusBadge(
                    request.status,
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: Color(0xFFE5E5E5),
            ),

            // Rental Information
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Requested: ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        TextSpan(
                          text:
                              request.equipmentName,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Dates: ${request.startDate} - ${request.endDate}',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        'Rs. ${_formatPrice(request.totalAmount)}',
                        style: const TextStyle(
                          color: primaryRed,
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // STATUS BADGE
  // ===========================

  Widget _statusBadge(
    String status,
  ) {
    final normalizedStatus =
        status.toLowerCase();

    Color background;
    Color textColor;

    switch (normalizedStatus) {
      case 'accepted':
        background =
            const Color(0xFFEAF8EF);
        textColor =
            const Color(0xFF27944A);
        break;

      case 'active':
        background =
            const Color(0xFFEAF8EF);
        textColor =
            const Color(0xFF27944A);
        break;

      case 'completed':
        background =
            const Color(0xFFEAF8EF);
        textColor =
            const Color(0xFF27944A);
        break;

      case 'rejected':
        background =
            const Color(0xFFFFE8EC);
        textColor = primaryRed;
        break;

      default:
        background =
            const Color(0xFFFFF4DD);
        textColor =
            const Color(0xFFC47A00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        normalizedStatus.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ===========================
  // PRICE FORMAT
  // ===========================

  String _formatPrice(
    double price,
  ) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }

    return price.toStringAsFixed(2);
  }

  // ===========================
  // BOTTOM NAVIGATION
  // ===========================

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
              _BottomNavItem(
                icon:
                    Icons.grid_view_rounded,
                label: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const _BottomNavItem(
                icon:
                    Icons.hexagon_outlined,
                label: 'My Items',
              ),

              const _BottomNavItem(
                icon: Icons
                    .shopping_bag_outlined,
                label: 'Requests',
                active: true,
              ),

              const _BottomNavItem(
                icon:
                    Icons.chat_bubble_outline,
                label: 'Messages',
              ),

              const _BottomNavItem(
                icon:
                    Icons.person_outline,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================
// EMPTY REQUESTS
// ===========================

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: Colors.grey,
          ),

          SizedBox(height: 15),

          Text(
            'No rental requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'New requests will appear here.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================
// BOTTOM NAV ITEM
// ===========================

class _BottomNavItem extends StatelessWidget {
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
        width: 65,
        height: 65,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  active ? red : Colors.grey,
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color:
                    active ? red : Colors.grey,
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