// import 'package:flutter/material.dart';

// class PickupReturnScreen extends StatefulWidget {
//   const PickupReturnScreen({super.key});

//   @override
//   State<PickupReturnScreen> createState() => _PickupReturnScreenState();
// }

// class _PickupReturnScreenState extends State<PickupReturnScreen> {
//   static const Color primaryRed = Color(0xFFED1235);
//   static const Color textGrey = Color(0xFF8A8A8A);

//   bool returnedWithoutDamage = false;
//   bool depositRefunded = false;
//   bool handoverConfirmed = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
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
//                         'Pickup & Return',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 28),

//                   // User / Booking card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: const Color(0xFFDDDDDD),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const CircleAvatar(
//                           radius: 21,
//                           backgroundColor: Color(0xFFEAEAEA),
//                           child: Icon(
//                             Icons.person,
//                             color: Colors.black54,
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Pushpa V.',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Booking: SS Cricket Bat',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: textGrey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 7,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFFFF0F2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Text(
//                             'Active',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: primaryRed,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // 1. Handover
//                   const Text(
//                     '1. Handover (Pickup)',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: const Color(0xFFDDDDDD),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         const Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Date & Time',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: textGrey,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Today, 4:00 PM',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Location',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: textGrey,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Kamal Sports Gear',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 handoverConfirmed = true;
//                               });

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                     'Handover confirmed successfully',
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: handoverConfirmed
//                                   ? const Color(0xFFBDBDBD)
//                                   : primaryRed,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(9),
//                               ),
//                             ),
//                             child: Text(
//                               handoverConfirmed
//                                   ? 'Handover Confirmed'
//                                   : 'Confirm Handover',
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 22),

//                   // 2. Return
//                   const Text(
//                     '2. Receive (Return)',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: const Color(0xFFDDDDDD),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Condition Check',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         CheckboxListTile(
//                           contentPadding: EdgeInsets.zero,
//                           controlAffinity:
//                               ListTileControlAffinity.leading,
//                           activeColor: primaryRed,
//                           value: returnedWithoutDamage,
//                           onChanged: (value) {
//                             setState(() {
//                               returnedWithoutDamage = value ?? false;
//                             });
//                           },
//                           title: const Text(
//                             'Item returned without damage',
//                             style: TextStyle(
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),

//                         CheckboxListTile(
//                           contentPadding: EdgeInsets.zero,
//                           controlAffinity:
//                               ListTileControlAffinity.leading,
//                           activeColor: primaryRed,
//                           value: depositRefunded,
//                           onChanged: (value) {
//                             setState(() {
//                               depositRefunded = value ?? false;
//                             });
//                           },
//                           title: const Text(
//                             'Security deposit (Rs. 2000) refunded',
//                             style: TextStyle(
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: OutlinedButton(
//                             onPressed: () {
//                               if (!returnedWithoutDamage ||
//                                   !depositRefunded) {
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       'Please complete both condition checks.',
//                                     ),
//                                   ),
//                                 );

//                                 return;
//                               }

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text(
//                                     'Return confirmed successfully',
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: primaryRed,
//                               side: const BorderSide(
//                                 color: primaryRed,
//                                 width: 1.5,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(9),
//                               ),
//                             ),
//                             child: const Text(
//                               'Confirm Return',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   // Report issue
//                   Center(
//                     child: TextButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Damage reporting will be connected later.',
//                             ),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Report an issue / damage',
//                         style: TextStyle(
//                           color: textGrey,
//                           fontSize: 14,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/booking_service.dart';

class PickupReturnScreen extends StatelessWidget {
  final String requestId;

  const PickupReturnScreen({
    super.key,
    required this.requestId,
  });

  static const Color primaryRed = Color(0xFFED1235);

  Future<void> _confirmHandover(
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(requestId)
          .update({
        'handoverConfirmed': true,
        'handoverConfirmedAt':
            FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await BookingService().syncSlotStatus(requestId, 'active');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Handover confirmed successfully',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to confirm handover: $error',
          ),
        ),
      );
    }
  }

  Future<void> _confirmReturn(
    BuildContext context,
    bool returnedWithoutDamage,
    bool depositRefunded,
  ) async {
    if (!returnedWithoutDamage ||
        !depositRefunded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete both condition checks.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(requestId)
          .update({
        'returnedWithoutDamage':
            returnedWithoutDamage,
        'depositRefunded': depositRefunded,
        'returnConfirmed': true,
        'returnConfirmedAt':
            FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      await BookingService().syncSlotStatus(requestId, 'completed');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return confirmed successfully',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to confirm return: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Something went wrong.',
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: primaryRed,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Rental request not found.',
              ),
            ),
          );
        }

        final data = snapshot.data!.data()
            as Map<String, dynamic>;

        final playerName =
            data['playerName']?.toString() ??
                'Player';

        final equipmentName =
            data['equipmentName']?.toString() ??
                'Equipment';

        final pickupLocation =
            data['pickupLocation']?.toString() ??
                'Provider location';

        final status =
            data['status']?.toString() ??
                'accepted';

        final handoverConfirmed =
            data['handoverConfirmed'] == true;

        return _PickupReturnContent(
          playerName: playerName,
          equipmentName: equipmentName,
          pickupLocation: pickupLocation,
          status: status,
          handoverConfirmed: handoverConfirmed,
          onConfirmHandover: () {
            _confirmHandover(context);
          },
          onConfirmReturn: (
            returnedWithoutDamage,
            depositRefunded,
          ) {
            _confirmReturn(
              context,
              returnedWithoutDamage,
              depositRefunded,
            );
          },
        );
      },
    );
  }
}

class _PickupReturnContent
    extends StatefulWidget {
  final String playerName;
  final String equipmentName;
  final String pickupLocation;
  final String status;
  final bool handoverConfirmed;
  final VoidCallback onConfirmHandover;
  final void Function(bool, bool)
      onConfirmReturn;

  const _PickupReturnContent({
    required this.playerName,
    required this.equipmentName,
    required this.pickupLocation,
    required this.status,
    required this.handoverConfirmed,
    required this.onConfirmHandover,
    required this.onConfirmReturn,
  });

  @override
  State<_PickupReturnContent> createState() =>
      _PickupReturnContentState();
}

class _PickupReturnContentState
    extends State<_PickupReturnContent> {
  static const Color primaryRed =
      Color(0xFFED1235);

  bool returnedWithoutDamage = false;
  bool depositRefunded = false;

  @override
  Widget build(BuildContext context) {
    final completed =
        widget.status == 'completed';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
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

                      const SizedBox(width: 14),

                      const Text(
                        'Pickup & Return',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          child: Icon(
                            Icons.person,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.playerName,
                                style:
                                    const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Booking: ${widget.equipmentName}',
                                style:
                                    const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFEEF1,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            widget.status
                                .toUpperCase(),
                            style: const TextStyle(
                              color: primaryRed,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '1. Handover (Pickup)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pickup Location',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          widget.pickupLocation,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                widget.handoverConfirmed ||
                                        completed
                                    ? null
                                    : widget
                                        .onConfirmHandover,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryRed,
                              foregroundColor:
                                  Colors.white,
                            ),
                            child: Text(
                              widget.handoverConfirmed ||
                                      completed
                                  ? 'Handover Confirmed'
                                  : 'Confirm Handover',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '2. Receive (Return)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Condition Check',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        CheckboxListTile(
                          value:
                              returnedWithoutDamage,
                          contentPadding:
                              EdgeInsets.zero,
                          activeColor: primaryRed,
                          title: const Text(
                            'Item returned without damage',
                          ),
                          onChanged:
                              completed
                                  ? null
                                  : (value) {
                                      setState(() {
                                        returnedWithoutDamage =
                                            value ??
                                                false;
                                      });
                                    },
                        ),

                        CheckboxListTile(
                          value: depositRefunded,
                          contentPadding:
                              EdgeInsets.zero,
                          activeColor: primaryRed,
                          title: const Text(
                            'Security deposit refunded',
                          ),
                          onChanged:
                              completed
                                  ? null
                                  : (value) {
                                      setState(() {
                                        depositRefunded =
                                            value ??
                                                false;
                                      });
                                    },
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: completed
                                ? null
                                : () {
                                    widget.onConfirmReturn(
                                      returnedWithoutDamage,
                                      depositRefunded,
                                    );
                                  },
                            child: Text(
                              completed
                                  ? 'Return Completed'
                                  : 'Confirm Return',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}