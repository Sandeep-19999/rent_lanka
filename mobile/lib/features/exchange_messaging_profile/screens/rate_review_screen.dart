import 'package:flutter/material.dart';

import '../services/review_service.dart';

class RateReviewScreen extends StatefulWidget {
  final String equipmentName;
  final String rentedDate;

  final String equipmentId;
  final String providerId;
  final String bookingId;

  const RateReviewScreen({
    super.key,
    this.equipmentName = 'SS Cricket Bat',
    this.rentedDate = '15 Sep',
    required this.equipmentId,
    required this.providerId,
    required this.bookingId,
  });

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const Color primaryRed = Color(0xFFED1235);

  static const Color darkText = Color(0xFF242424);

  final TextEditingController _reviewController = TextEditingController();

  final ReviewService _reviewService = ReviewService();

  int _selectedRating = 0;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasExistingReview = false;

  @override
  void initState() {
    super.initState();

    _loadExistingReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingReview() async {
    try {
      final review = await _reviewService.getReview(widget.bookingId);

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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveReview() async {
    final String review = _reviewController.text.trim();

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating.')));

      return;
    }

    if (review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your review.')),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _reviewService.saveReview(
        providerId: widget.providerId,
        equipmentId: widget.equipmentId,
        bookingId: widget.bookingId,
        rating: _selectedRating,
        comment: review,
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
            _hasExistingReview
                ? 'Review saved successfully.'
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: const Text('Are you sure you want to delete this review?'),
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
      await _reviewService.deleteReview(widget.bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        _hasExistingReview = false;
        _selectedRating = 0;
        _reviewController.clear();
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryRed)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 42),

                  _buildEquipmentInfo(),

                  const SizedBox(height: 18),

                  const Divider(color: Color(0xFFE8E8E8), thickness: 1),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 14),

                  _buildStarRating(),

                  const SizedBox(height: 24),

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

                  const Spacer(),

                  if (_hasExistingReview)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _deleteReview,
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
                      onPressed: _isSaving ? null : _saveReview,
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
                                strokeWidth: 2.3,
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

        const SizedBox(width: 34),

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

  Widget _buildEquipmentInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sports_cricket,
            color: Color(0xFF1687D9),
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.equipmentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Rented on ${widget.rentedDate}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9B9B9B)),
              ),
            ],
          ),
        ),
      ],
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
