import 'package:flutter/material.dart';

import '../models/review_equipment_option.dart';
import '../services/completed_rental_service.dart';
import '../services/review_service.dart';

class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  static const Color greyText = Color(0xFF929292);

  final TextEditingController _reviewController = TextEditingController();

  final ReviewService _reviewService = ReviewService();

  final CompletedRentalService _completedRentalService =
      CompletedRentalService();

  ReviewEquipmentOption? _selectedEquipment;

  int _selectedRating = 0;

  bool _isLoadingReview = false;
  bool _isSaving = false;
  bool _hasExistingReview = false;
  bool _showEquipmentOptions = false;

  String? _loadedBookingId;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedEquipmentReview() async {
    final selected = _selectedEquipment;

    if (selected == null) {
      return;
    }

    setState(() {
      _isLoadingReview = true;
      _selectedRating = 0;
      _reviewController.clear();
      _hasExistingReview = false;
    });

    try {
      final review = await _reviewService.getReview(selected.bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        if (review != null) {
          _selectedRating = review.rating;
          _reviewController.text = review.comment;
          _hasExistingReview = true;
        }

        _loadedBookingId = selected.bookingId;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load review: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
        });
      }
    }
  }

  Future<void> _selectEquipment(ReviewEquipmentOption equipment) async {
    setState(() {
      _selectedEquipment = equipment;
      _showEquipmentOptions = false;
    });

    if (_loadedBookingId != equipment.bookingId) {
      await _loadSelectedEquipmentReview();
    }
  }

  Future<void> _saveReview() async {
    final selected = _selectedEquipment;

    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select equipment.')));
      return;
    }

    final String reviewText = _reviewController.text.trim();

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating.')));
      return;
    }

    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your review.')),
      );
      return;
    }

    final bool wasExistingReview = _hasExistingReview;

    setState(() {
      _isSaving = true;
    });

    try {
      await _reviewService.saveReview(
        providerId: selected.providerId,
        equipmentId: selected.equipmentId,
        bookingId: selected.bookingId,
        rating: _selectedRating,
        comment: reviewText,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasExistingReview = true;
        _loadedBookingId = selected.bookingId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasExistingReview
                ? 'Review updated successfully.'
                : 'Review submitted successfully.',
          ),
          backgroundColor: const Color(0xFF2E9B50),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save review: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    final selected = _selectedEquipment;

    if (selected == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: Text(
            'Are you sure you want to delete your review for ${selected.equipmentName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete', style: TextStyle(color: primaryRed)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _reviewService.deleteReview(selected.bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedRating = 0;
        _reviewController.clear();
        _hasExistingReview = false;
        _loadedBookingId = selected.bookingId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete review: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewEquipmentOption>>(
      stream: _completedRentalService.watchCompletedRentals(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: primaryRed),
              ),
            ),
          );
        }

        final rentals = snapshot.data ?? [];

        if (rentals.isEmpty) {
          return _buildEmptyScreen();
        }

        _prepareSelection(rentals);

        return _buildMainScreen(rentals);
      },
    );
  }

  void _prepareSelection(List<ReviewEquipmentOption> rentals) {
    if (_selectedEquipment == null) {
      _selectedEquipment = rentals.first;

      if (_loadedBookingId != rentals.first.bookingId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadSelectedEquipmentReview();
          }
        });
      }

      return;
    }

    final bool stillExists = rentals.any(
      (rental) => rental.bookingId == _selectedEquipment!.bookingId,
    );

    if (!stillExists) {
      _selectedEquipment = rentals.first;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSelectedEquipmentReview();
        }
      });
    }
  }

  Widget _buildMainScreen(List<ReviewEquipmentOption> rentals) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 34),

                  const Text(
                    'Select equipment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: greyText,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildEquipmentSelector(),

                  if (_showEquipmentOptions) ...[
                    const SizedBox(height: 8),
                    _buildEquipmentOptionsList(rentals),
                  ],

                  const SizedBox(height: 28),

                  const Divider(color: Color(0xFFE8E8E8)),

                  const SizedBox(height: 28),

                  const Center(
                    child: Text(
                      'How was your rental?',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_isLoadingReview)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: CircularProgressIndicator(color: primaryRed),
                      ),
                    )
                  else
                    _buildStarRating(),

                  const SizedBox(height: 36),

                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _reviewController,
                    enabled: !_isLoadingReview,
                    minLines: 5,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                      contentPadding: const EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (_hasExistingReview) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _deleteReview,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: const BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Delete review',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving || _isLoadingReview
                          ? null
                          : _saveReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _hasExistingReview
                                  ? 'Update review'
                                  : 'Submit review',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new, size: 23, color: darkText),
          ),
        ),

        const SizedBox(width: 25),

        const Expanded(
          child: Text(
            'Rate your experience',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    final selected = _selectedEquipment;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          setState(() {
            _showEquipmentOptions = !_showEquipmentOptions;
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryRed, width: 1.3),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.sports,
                  color: Color(0xFF1687D9),
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected?.equipmentName ?? 'Select equipment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    if (selected != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Completed ${selected.rentedDate}',
                        style: const TextStyle(fontSize: 12, color: greyText),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                _showEquipmentOptions
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: darkText,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentOptionsList(List<ReviewEquipmentOption> rentals) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 210),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: rentals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 7),
        itemBuilder: (context, index) {
          final equipment = rentals[index];

          final bool isSelected =
              equipment.bookingId == _selectedEquipment?.bookingId;

          return InkWell(
            onTap: () {
              _selectEquipment(equipment);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF2F4)
                    : const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected ? primaryRed : const Color(0xFFE4E4E4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sports,
                      color: Color(0xFF1687D9),
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.equipmentName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Completed ${equipment.rentedDate}',
                          style: const TextStyle(fontSize: 11, color: greyText),
                        ),
                      ],
                    ),
                  ),

                  if (isSelected)
                    const Icon(Icons.check_circle, color: primaryRed, size: 21),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final int starNumber = index + 1;

        final bool isSelected = starNumber <= _selectedRating;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedRating = starNumber;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.star,
              size: 41,
              color: isSelected
                  ? const Color(0xFFFFB000)
                  : const Color(0xFFE2E2E2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),

                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 58,
                            color: Color(0xFFB5B5B5),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'No completed rentals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'You can review equipment after a rental is completed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: greyText),
                          ),
                        ],
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

  Widget _buildErrorScreen(Object? error) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: Center(
                      child: Text(
                        'Unable to load completed rentals.\n$error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: greyText),
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
}
