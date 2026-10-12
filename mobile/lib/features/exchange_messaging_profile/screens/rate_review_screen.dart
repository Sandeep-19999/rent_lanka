import 'package:flutter/material.dart';

import '../models/review_equipment_option.dart';
import '../models/review_model.dart';
import '../services/completed_rental_service.dart';
import '../services/review_service.dart';
import '../../booking_payment/screens/booking/my_bookings_screen.dart';

class RateReviewScreen extends StatefulWidget {
  final String? initialBookingId;
  final String? equipmentId;
  final String? equipmentName;
  final bool showEditor;
  final ReviewService? reviewService;
  final CompletedRentalService? completedRentalService;
  const RateReviewScreen({
    super.key,
    this.initialBookingId,
    this.equipmentId,
    this.equipmentName,
    this.showEditor = false,
    this.reviewService,
    this.completedRentalService,
  });

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const Color primaryRed = Color(0xFFED1235);
  static const Color darkText = Color(0xFF242424);
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color starColor = Color(0xFFFFB400);

  final TextEditingController _reviewController = TextEditingController();

  late final ReviewService _reviewService =
      widget.reviewService ?? ReviewService();

  late final CompletedRentalService _completedRentalService =
      widget.completedRentalService ?? CompletedRentalService();
  late final Stream<List<ReviewEquipmentOption>> _completedRentals =
      _completedRentalService.watchCompletedRentals();
  late final Stream<List<ReviewModel>> _equipmentReviews = _reviewService
      .watchEquipmentReviews(widget.equipmentId!);
  final Map<String, Future<String>> _reviewerNames = {};
  final Map<String, Future<String>> _equipmentNames = {};
  late Stream<List<ReviewModel>> _myReviews = _reviewService.watchMyReviews();
  String? _deletingReviewId;

  void _editSubmittedReview(ReviewModel review) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RateReviewScreen(
          initialBookingId: review.bookingId,
          equipmentId: review.equipmentId,
          showEditor: true,
          reviewService: _reviewService,
          completedRentalService: widget.completedRentalService,
        ),
      ),
    );
  }

  Future<void> _deleteSubmittedReview(ReviewModel review) async {
    if (_deletingReviewId != null ||
        review.reviewerId != _reviewService.signedInUserId) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('Your review will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Review'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deletingReviewId = review.id);
    try {
      await _reviewService.deleteReview(review.bookingId);
      if (mounted) _showMessage('Review deleted successfully.');
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to delete your review. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _deletingReviewId = null);
    }
  }

  ReviewEquipmentOption? _selectedEquipment;

  int _selectedRating = 0;

  bool _isLoadingReview = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasExistingReview = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReview() async {
    final ReviewEquipmentOption? selected = _selectedEquipment;

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

      if (!mounted) return;

      setState(() {
        if (review != null) {
          _selectedRating = review.rating;
          _reviewController.text = review.comment;
          _hasExistingReview = true;
        }
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to load review: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
        });
      }
    }
  }

  Future<void> _saveReview() async {
    final ReviewEquipmentOption? selected = _selectedEquipment;

    if (selected == null) {
      _showMessage('Open a completed booking to write your review.');
      return;
    }

    if (_selectedRating == 0) {
      _showMessage('Please select a star rating.');
      return;
    }

    final String comment = _reviewController.text.trim();

    if (comment.isEmpty) {
      _showMessage('Please write a short review.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool wasExisting = _hasExistingReview;

    try {
      await _reviewService.saveReview(
        providerId: selected.providerId,
        equipmentId: selected.equipmentId,
        bookingId: selected.bookingId,
        rating: _selectedRating,
        comment: comment,
      );

      if (!mounted) return;

      setState(() {
        _hasExistingReview = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasExisting
                ? 'Review updated successfully.'
                : 'Review submitted successfully.',
          ),
          backgroundColor: const Color(0xFF2E9B50),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to save review: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    final ReviewEquipmentOption? selected = _selectedEquipment;

    if (selected == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete review?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Your review for ${selected.equipmentName} will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Keep Review',
                style: TextStyle(color: darkText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _reviewService.deleteReview(selected.bookingId);

      if (!mounted) return;

      setState(() {
        _selectedRating = 0;
        _reviewController.clear();
        _hasExistingReview = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to delete review: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _prepareInitialSelection(List<ReviewEquipmentOption> rentals) {
    if (_selectedEquipment != null || rentals.isEmpty) return;
    _selectedEquipment = rentals.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.equipmentId != null && !widget.showEditor) {
      return _buildEquipmentReviews();
    }
    if (widget.initialBookingId == null && widget.equipmentId == null) {
      return _buildBookingEntry();
    }
    return StreamBuilder<List<ReviewEquipmentOption>>(
      stream: _completedRentals,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
          );
        }

        final List<ReviewEquipmentOption> rentals = (snapshot.data ?? [])
            .where(
              (rental) =>
                  widget.equipmentId == null ||
                  rental.equipmentId == widget.equipmentId,
            )
            .where(
              (rental) =>
                  widget.initialBookingId == null ||
                  rental.bookingId == widget.initialBookingId,
            )
            .where(
              (rental) =>
                  _selectedEquipment == null ||
                  rental.bookingId == _selectedEquipment!.bookingId,
            )
            .toList();

        if (rentals.isEmpty) {
          return _buildEmptyScreen();
        }

        _prepareInitialSelection(rentals);

        return _buildMainScreen();
      },
    );
  }

  Widget _buildEquipmentReviews() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
        ),
        titleSpacing: 0,
        title: const Text(
          'Ratings & Reviews',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: StreamBuilder<List<ReviewModel>>(
              stream: _equipmentReviews,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Unable to load ratings and reviews. Please try again.',
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  );
                }
                final reviews = snapshot.data!;
                final average = ReviewService.averageRating(reviews);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.equipmentName ?? 'Equipment',
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: starColor),
                              const SizedBox(width: 6),
                              Text(
                                average == null
                                    ? 'No ratings yet'
                                    : '${average.toStringAsFixed(1)} / 5',
                                key: const ValueKey('equipment-review-average'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                                style: const TextStyle(color: greyText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_reviewService.signedInUserId != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => RateReviewScreen(
                              equipmentId: widget.equipmentId,
                              equipmentName: widget.equipmentName,
                              showEditor: true,
                              reviewService: _reviewService,
                              completedRentalService:
                                  widget.completedRentalService,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write or manage your review'),
                      ),
                    if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No reviews yet for this equipment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: greyText),
                        ),
                      ),
                    for (final review in reviews) ...[
                      const SizedBox(height: 12),
                      _buildSubmittedReview(review),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedReview(ReviewModel review) {
    final date = (review.updatedAt ?? review.createdAt)?.toLocal();
    return Container(
      key: ValueKey('equipment-review-${review.id}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _reviewerNames.putIfAbsent(
              review.reviewerId,
              () => _reviewService.getReviewerName(review.reviewerId),
            ),
            builder: (context, snapshot) => Text(
              snapshot.data ?? 'Rent Lanka User',
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                Icon(
                  star <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: starColor,
                  size: 18,
                ),
              if (date != null) ...[
                const SizedBox(width: 10),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: greyText, fontSize: 11),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(color: greyText, height: 1.4),
          ),
          if (review.reviewerId == _reviewService.signedInUserId) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _deletingReviewId != null
                      ? null
                      : () => _editSubmittedReview(review),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: _deletingReviewId != null
                      ? null
                      : () => _deleteSubmittedReview(review),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(
                    _deletingReviewId == review.id ? 'Deleting…' : 'Delete',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroCard(),

                  const SizedBox(height: 24),

                  const Text(
                    'Reviewing this item',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildReviewItem(),

                  const SizedBox(height: 28),

                  _buildRatingCard(),

                  const SizedBox(height: 24),

                  const Text(
                    'Write your review',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Tell others about your experience with this equipment.',
                    style: TextStyle(
                      color: greyText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _reviewController,
                    enabled: !_isLoadingReview && !_isSaving && !_isDeleting,
                    minLines: 5,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Example: Equipment was in good condition and the provider was helpful...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (_hasExistingReview) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2E9B50),
                            size: 21,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You already reviewed this rental. You can update or delete your review.',
                              style: TextStyle(
                                color: Color(0xFF39764B),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving || _isLoadingReview || _isDeleting
                          ? null
                          : _saveReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryRed.withValues(
                          alpha: 0.55,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.star_rounded),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : _hasExistingReview
                            ? 'Update Review'
                            : 'Submit Review',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  if (_hasExistingReview) ...[
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting || _isSaving
                            ? null
                            : _deleteReview,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: const BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryRed,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                              ),
                        label: const Text(
                          'Delete Review',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.rate_review_outlined,
              color: primaryRed,
              size: 26,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share your experience',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your feedback helps other Rent Lanka users choose reliable equipment.',
                  style: TextStyle(color: greyText, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingEntry() => Scaffold(
    backgroundColor: backgroundColor,
    appBar: AppBar(title: const Text('Rate & Review')),
    body: _reviewService.signedInUserId == null
        ? const Center(child: Text('Sign in to view and manage your reviews.'))
        : StreamBuilder<List<ReviewModel>>(
            stream: _myReviews,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load your reviews. Please try again.',
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => _myReviews = _reviewService.watchMyReviews(),
                        ),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryRed),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Your reviews',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Edit or delete a review below. Open a completed booking or equipment item to write a new review.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsScreen(),
                          ),
                        ),
                        child: const Text('My Bookings'),
                      ),
                      if (snapshot.data!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'You have not submitted any reviews yet.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      for (final review in snapshot.data!) ...[
                        const SizedBox(height: 20),
                        FutureBuilder<String>(
                          future: _equipmentNames.putIfAbsent(
                            review.equipmentId,
                            () => _reviewService.getEquipmentName(
                              review.equipmentId,
                            ),
                          ),
                          builder: (_, name) => Text(
                            name.data ?? 'Equipment',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSubmittedReview(review),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
  );

  Widget _buildReviewItem() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        const Icon(Icons.sports_rounded, color: primaryRed, size: 30),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedEquipment?.equipmentName ?? 'Equipment',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Booking: ${_selectedEquipment?.bookingId ?? ''}',
                style: const TextStyle(color: greyText, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Text(
            'How was your rental?',
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _ratingLabel(),
            style: TextStyle(
              color: _selectedRating == 0 ? greyText : starColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          if (_isLoadingReview)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(color: primaryRed),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final int value = index + 1;

                final bool selected = value <= _selectedRating;

                return InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    setState(() {
                      _selectedRating = value;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 43,
                      color: selected ? starColor : const Color(0xFFD2D2D2),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  String _ratingLabel() {
    switch (_selectedRating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
        ),
        titleSpacing: 0,
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFFFEEF1),
                child: Icon(
                  Icons.rate_review_outlined,
                  color: primaryRed,
                  size: 38,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'No completed rentals yet',
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'After you complete a rental, you can rate the equipment and share your experience here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: greyText, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
        ),
        titleSpacing: 0,
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: primaryRed, size: 52),
              SizedBox(height: 14),
              Text(
                'Unable to load completed rentals',
                style: TextStyle(
                  color: darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
