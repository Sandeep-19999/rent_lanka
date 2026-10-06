import 'package:flutter/material.dart';

import '../models/review_equipment_option.dart';
import '../services/review_service.dart';

class RateReviewScreen extends StatefulWidget {
  final List<ReviewEquipmentOption>? equipmentOptions;

  final String equipmentId;
  final String providerId;
  final String bookingId;
  final String equipmentName;
  final String rentedDate;

  const RateReviewScreen({
    super.key,
    this.equipmentOptions,
    this.equipmentId = 'demo_ss_cricket_bat',
    this.providerId = 'demo_provider_001',
    this.bookingId = 'demo_booking_001',
    this.equipmentName = 'SS Cricket Bat',
    this.rentedDate = '15 Sep',
  });

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF929292);

  final TextEditingController _reviewController = TextEditingController();

  final ReviewService _reviewService = ReviewService();

  late final List<ReviewEquipmentOption> _equipmentOptions;

  ReviewEquipmentOption? _selectedEquipment;

  int _selectedRating = 0;

  bool _isLoadingReview = true;
  bool _isSaving = false;
  bool _hasExistingReview = false;

  bool _showEquipmentOptions = false;

  @override
  void initState() {
    super.initState();

    if (widget.equipmentOptions != null &&
        widget.equipmentOptions!.isNotEmpty) {
      _equipmentOptions = List<ReviewEquipmentOption>.from(
        widget.equipmentOptions!,
      );
    } else {
      _equipmentOptions = [
        ReviewEquipmentOption(
          equipmentId: widget.equipmentId,
          providerId: widget.providerId,
          bookingId: widget.bookingId,
          equipmentName: widget.equipmentName,
          rentedDate: widget.rentedDate,
        ),
      ];
    }

    _selectedEquipment = _equipmentOptions.first;

    _loadSelectedEquipmentReview();
  }

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

      if (review != null) {
        _selectedRating = review.rating;
        _reviewController.text = review.comment;
        _hasExistingReview = true;
      }
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
    if (equipment.bookingId == _selectedEquipment?.bookingId) {
      setState(() {
        _showEquipmentOptions = false;
      });
      return;
    }

    setState(() {
      _selectedEquipment = equipment;
      _showEquipmentOptions = false;
    });

    await _loadSelectedEquipmentReview();
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
          content: Text('Delete your review for ${selected.equipmentName}?'),
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
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review deleted.')));
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
    final selected = _selectedEquipment;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          if (_showEquipmentOptions) {
            setState(() {
              _showEquipmentOptions = false;
            });
          }
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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

                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: _showEquipmentOptions
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _buildEquipmentOptionsList(),
                      secondChild: const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 22),

                    const Divider(color: Color(0xFFE8E8E8)),

                    const SizedBox(height: 20),

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

                    const SizedBox(height: 16),

                    if (_isLoadingReview)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: CircularProgressIndicator(color: primaryRed),
                        ),
                      )
                    else
                      _buildStarRating(),

                    const SizedBox(height: 28),

                    const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 9),

                    TextField(
                      controller: _reviewController,
                      enabled: !_isLoadingReview,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: selected == null
                            ? 'Select equipment first'
                            : 'Share your experience...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FB),
                        contentPadding: const EdgeInsets.all(15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
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

                    const Spacer(),

                    if (_hasExistingReview)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
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
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),

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
                child: selected == null
                    ? const Text(
                        'Select equipment',
                        style: TextStyle(color: greyText),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.equipmentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Rented on ${selected.rentedDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: greyText,
                            ),
                          ),
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

  Widget _buildEquipmentOptionsList() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
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
      child: Column(
        children: _equipmentOptions.map((equipment) {
          final bool isSelected =
              equipment.bookingId == _selectedEquipment?.bookingId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                _selectEquipment(equipment);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFF2F4)
                      : const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? primaryRed : const Color(0xFFE4E4E4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.sports,
                        color: Color(0xFF1687D9),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.equipmentName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Rented on ${equipment.rentedDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: greyText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: primaryRed,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
}
