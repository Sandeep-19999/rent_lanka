// import 'package:flutter/material.dart';

// class AvailabilityScreen extends StatefulWidget {
//   const AvailabilityScreen({super.key});

//   @override
//   State<AvailabilityScreen> createState() => _AvailabilityScreenState();
// }

// class _AvailabilityScreenState extends State<AvailabilityScreen> {
//   static const Color primaryRed = Color(0xFFED0029);
//   static const Color textGrey = Color(0xFF8D8D8D);

//   DateTime currentMonth = DateTime(2026, 9);

//   // Figma screenshot එකේ selected dates
//   final Set<DateTime> selectedDates = {
//     DateTime(2026, 9, 13),
//     DateTime(2026, 9, 14),
//   };

//   // Figma screenshot එකේ unavailable dates
//   final Set<DateTime> unavailableDates = {
//     DateTime(2026, 9, 10),
//     DateTime(2026, 9, 11),
//     DateTime(2026, 9, 12),
//   };

//   DateTime _normalize(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }

//   bool _contains(Set<DateTime> dates, DateTime date) {
//     return dates.contains(_normalize(date));
//   }

//   void _toggleDate(DateTime date) {
//     if (date.month != currentMonth.month) return;

//     final normalized = _normalize(date);

//     setState(() {
//       if (selectedDates.contains(normalized)) {
//         selectedDates.remove(normalized);
//       } else if (unavailableDates.contains(normalized)) {
//         unavailableDates.remove(normalized);
//       } else {
//         selectedDates.add(normalized);
//       }
//     });
//   }

//   void _previousMonth() {
//     setState(() {
//       currentMonth = DateTime(
//         currentMonth.year,
//         currentMonth.month - 1,
//       );
//     });
//   }

//   void _nextMonth() {
//     setState(() {
//       currentMonth = DateTime(
//         currentMonth.year,
//         currentMonth.month + 1,
//       );
//     });
//   }

//   String _monthName(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];

//     return months[month - 1];
//   }

//   List<DateTime> _calendarDates() {
//     final firstDay = DateTime(
//       currentMonth.year,
//       currentMonth.month,
//       1,
//     );

//     // Sunday = 0
//     final daysBefore = firstDay.weekday % 7;

//     final startDate = firstDay.subtract(
//       Duration(days: daysBefore),
//     );

//     return List.generate(
//       42,
//       (index) => startDate.add(
//         Duration(days: index),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dates = _calendarDates();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
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
//                         'Availability',
//                         style: TextStyle(
//                           fontSize: 23,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // Equipment card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF9F9FA),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: const Color(0xFFE6E6E6),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 42,
//                           height: 42,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(9),
//                             border: Border.all(
//                               color: const Color(0xFFE5E5E5),
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.sports_cricket,
//                             size: 28,
//                             color: Colors.black87,
//                           ),
//                         ),

//                         const SizedBox(width: 14),

//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Cricket Bat',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Tap dates to block/unblock',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: textGrey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Calendar card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.fromLTRB(
//                       10,
//                       18,
//                       10,
//                       14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: const Color(0xFFE5E5E5),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Month navigation
//                         Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                           children: [
//                             IconButton(
//                               onPressed: _previousMonth,
//                               icon: const Icon(
//                                 Icons.chevron_left,
//                                 size: 30,
//                               ),
//                             ),

//                             Text(
//                               '${_monthName(currentMonth.month)} '
//                               '${currentMonth.year}',
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),

//                             IconButton(
//                               onPressed: _nextMonth,
//                               icon: const Icon(
//                                 Icons.chevron_right,
//                                 size: 30,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 8),

//                         // Weekdays
//                         const Row(
//                           children: [
//                             _WeekDay('SU'),
//                             _WeekDay('MO'),
//                             _WeekDay('TU'),
//                             _WeekDay('WE'),
//                             _WeekDay('TH'),
//                             _WeekDay('FR'),
//                             _WeekDay('SA'),
//                           ],
//                         ),

//                         const SizedBox(height: 8),

//                         const Divider(
//                           height: 1,
//                           color: Color(0xFFF0F0F0),
//                         ),

//                         const SizedBox(height: 6),

//                         // Calendar grid
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics:
//                               const NeverScrollableScrollPhysics(),
//                           itemCount: dates.length,
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 7,
//                             childAspectRatio: 1,
//                           ),
//                           itemBuilder: (context, index) {
//                             final date = dates[index];

//                             return _buildDateCell(date);
//                           },
//                         ),

//                         const SizedBox(height: 10),

//                         // Legend
//                         const Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment.spaceEvenly,
//                           children: [
//                             _LegendItem(
//                               type: _LegendType.selected,
//                               text: 'Selected',
//                             ),
//                             _LegendItem(
//                               type: _LegendType.available,
//                               text: 'Available',
//                             ),
//                             _LegendItem(
//                               type: _LegendType.unavailable,
//                               text: 'Unavailable',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 26),

//                   // Save button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Availability saved successfully',
//                             ),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryRed,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(28),
//                         ),
//                       ),
//                       child: const Text(
//                         'Save availability',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
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

//   Widget _buildDateCell(DateTime date) {
//     final isCurrentMonth =
//         date.month == currentMonth.month;

//     final isSelected = _contains(
//       selectedDates,
//       date,
//     );

//     final isUnavailable = _contains(
//       unavailableDates,
//       date,
//     );

//     // Screenshot එකේ 19 වගේ available outline example
//     final isHighlightedAvailable =
//         date.year == 2026 &&
//         date.month == 9 &&
//         date.day == 19;

//     return InkWell(
//       onTap: () {
//         _toggleDate(date);
//       },
//       borderRadius: BorderRadius.circular(30),
//       child: Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isSelected
//                     ? primaryRed
//                     : isUnavailable
//                         ? const Color(0xFFF0F0F2)
//                         : Colors.transparent,
//                 border: isHighlightedAvailable &&
//                         !isSelected &&
//                         !isUnavailable
//                     ? Border.all(
//                         color: primaryRed,
//                         width: 2,
//                       )
//                     : null,
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 '${date.day}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: !isCurrentMonth
//                       ? const Color(0xFFCCCCCC)
//                       : isSelected
//                           ? Colors.white
//                           : isUnavailable
//                               ? const Color(0xFFAAAAAA)
//                               : isHighlightedAvailable
//                                   ? primaryRed
//                                   : Colors.black87,
//                 ),
//               ),
//             ),

//             if (isUnavailable)
//               Transform.rotate(
//                 angle: -0.75,
//                 child: Container(
//                   width: 30,
//                   height: 1.3,
//                   color: const Color(0xFFD5D5D5),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _WeekDay extends StatelessWidget {
//   final String text;

//   const _WeekDay(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Center(
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Color(0xFF929292),
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum _LegendType {
//   selected,
//   available,
//   unavailable,
// }

// class _LegendItem extends StatelessWidget {
//   final _LegendType type;
//   final String text;

//   const _LegendItem({
//     required this.type,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Widget circle;

//     switch (type) {
//       case _LegendType.selected:
//         circle = Container(
//           width: 12,
//           height: 12,
//           decoration: const BoxDecoration(
//             color: Color(0xFFED0029),
//             shape: BoxShape.circle,
//           ),
//         );
//         break;

//       case _LegendType.available:
//         circle = Container(
//           width: 13,
//           height: 13,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.black,
//               width: 1.5,
//             ),
//           ),
//         );
//         break;

//       case _LegendType.unavailable:
//         circle = Container(
//           width: 12,
//           height: 12,
//           decoration: const BoxDecoration(
//             color: Color(0xFFCCCCCC),
//             shape: BoxShape.circle,
//           ),
//         );
//         break;
//     }

//     return Row(
//       children: [
//         circle,
//         const SizedBox(width: 7),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 11,
//             color: Color(0xFF444444),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AvailabilityScreen extends StatefulWidget {
  final String equipmentId;

  const AvailabilityScreen({
    super.key,
    required this.equipmentId,
  });

  @override
  State<AvailabilityScreen> createState() =>
      _AvailabilityScreenState();
}

class _AvailabilityScreenState
    extends State<AvailabilityScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color textGrey = Color(0xFF8A8A8A);

  late DateTime currentMonth;

  final Set<String> unavailableDates = {};

  bool isLoading = true;
  bool isSaving = false;

  String equipmentName = 'Equipment';

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    currentMonth = DateTime(
      now.year,
      now.month,
    );

    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.equipmentId)
          .get();

      if (!document.exists) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final data =
          document.data() as Map<String, dynamic>;

      final savedDates =
          data['unavailableDates'];

      setState(() {
        equipmentName =
            data['name']?.toString() ??
                'Equipment';

        if (savedDates is List) {
          unavailableDates.clear();

          unavailableDates.addAll(
            savedDates.map(
              (date) => date.toString(),
            ),
          );
        }

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load availability: $error',
          ),
        ),
      );
    }
  }

  Future<void> _saveAvailability() async {
    setState(() {
      isSaving = true;
    });

    try {
      final dates =
          unavailableDates.toList()
            ..sort();

      await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.equipmentId)
          .set(
        {
          'unavailableDates': dates,
          'availabilityUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Availability saved successfully!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save availability: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String _dateKey(DateTime date) {
    final year =
        date.year.toString();

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    return '$year-$month-$day';
  }

  bool _isUnavailable(DateTime date) {
    return unavailableDates.contains(
      _dateKey(date),
    );
  }

  void _toggleDate(DateTime date) {
    if (date.month != currentMonth.month ||
        date.year != currentMonth.year) {
      return;
    }

    final key = _dateKey(date);

    setState(() {
      if (unavailableDates.contains(key)) {
        unavailableDates.remove(key);
      } else {
        unavailableDates.add(key);
      }
    });
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
      );
    });
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  List<DateTime> _calendarDates() {
    final firstDay = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final daysBefore =
        firstDay.weekday % 7;

    final startDate =
        firstDay.subtract(
      Duration(
        days: daysBefore,
      ),
    );

    return List.generate(
      42,
      (index) => startDate.add(
        Duration(
          days: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dates =
        _calendarDates();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color: primaryRed,
                    ),
                  )
                : SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Header
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
                              'Availability',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Equipment card
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFF9F9FA,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            border: Border.all(
                              color: const Color(
                                0xFFE6E6E6,
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
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xFFE5E5E5,
                                    ),
                                  ),
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .sports_cricket,
                                  size: 27,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      equipmentName,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            15,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    const Text(
                                      'Tap dates to block or unblock',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
                                        color:
                                            textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // Calendar Card
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            10,
                            18,
                            10,
                            15,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFE5E5E5,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Month selector
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed:
                                        _previousMonth,
                                    icon:
                                        const Icon(
                                      Icons
                                          .chevron_left,
                                      size: 30,
                                    ),
                                  ),

                                  Text(
                                    '${_monthName(currentMonth.month)} '
                                    '${currentMonth.year}',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),

                                  IconButton(
                                    onPressed:
                                        _nextMonth,
                                    icon:
                                        const Icon(
                                      Icons
                                          .chevron_right,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              // Week days
                              const Row(
                                children: [
                                  _WeekDay(
                                    'SU',
                                  ),
                                  _WeekDay(
                                    'MO',
                                  ),
                                  _WeekDay(
                                    'TU',
                                  ),
                                  _WeekDay(
                                    'WE',
                                  ),
                                  _WeekDay(
                                    'TH',
                                  ),
                                  _WeekDay(
                                    'FR',
                                  ),
                                  _WeekDay(
                                    'SA',
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              const Divider(
                                height: 1,
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount:
                                    dates.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      7,
                                  childAspectRatio:
                                      1,
                                ),
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  return _buildDateCell(
                                    dates[
                                        index],
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // Legend
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  _LegendDot(
                                    color:
                                        primaryRed,
                                  ),

                                  SizedBox(
                                    width: 7,
                                  ),

                                  Text(
                                    'Unavailable',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 25,
                                  ),

                                  _LegendDot(
                                    color: Color(
                                      0xFFEAEAEA,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 7,
                                  ),

                                  Text(
                                    'Available',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // Information
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFFFFF8E8,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Icon(
                                Icons
                                    .info_outline,
                                size: 20,
                                color: Color(
                                  0xFFC48700,
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  'Red dates are blocked and customers will not be able to rent the item on those dates.',
                                  style:
                                      TextStyle(
                                    fontSize: 12,
                                    color:
                                        Color(
                                      0xFF765500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // Save
                        SizedBox(
                          width:
                              double.infinity,
                          height: 54,
                          child:
                              ElevatedButton(
                            onPressed:
                                isSaving
                                    ? null
                                    : _saveAvailability,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryRed,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  const Color(
                                0xFFBBBBBB,
                              ),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  28,
                                ),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                      color: Colors
                                          .white,
                                    ),
                                  )
                                : const Text(
                                    'Save Availability',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
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

  Widget _buildDateCell(
    DateTime date,
  ) {
    final bool current =
        date.month ==
                currentMonth.month &&
            date.year ==
                currentMonth.year;

    final bool unavailable =
        _isUnavailable(date);

    return InkWell(
      onTap:
          current
              ? () =>
                  _toggleDate(date)
              : null,
      borderRadius:
          BorderRadius.circular(30),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            shape: BoxShape.circle,
            color: unavailable
                ? primaryRed
                : Colors.transparent,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color: !current
                  ? const Color(
                      0xFFCCCCCC,
                    )
                  : unavailable
                      ? Colors.white
                      : Colors
                          .black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekDay
    extends StatelessWidget {
  final String text;

  const _WeekDay(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                Color(
              0xFF929292,
            ),
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LegendDot
    extends StatelessWidget {
  final Color color;

  const _LegendDot({
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 12,
      height: 12,
      decoration:
          BoxDecoration(
        color: color,
        shape:
            BoxShape.circle,
      ),
    );
  }
}