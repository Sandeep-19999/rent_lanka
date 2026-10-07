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
  static const Color greyText = Color(0xFF7D7D7D);
  static const Color borderColor = Color(0xFFE7E7E7);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color starColor = Color(0xFFFFB400);

  final TextEditingController _reviewController = TextEditingController();

  final ReviewService _reviewService = ReviewService();

  final CompletedRentalService _completedRentalService =
      CompletedRentalService();

  ReviewEquipmentOption? _selectedEquipment;

  int _selectedRating = 0;

  bool _isLoadingReview = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasExistingReview = false;

  String? _loadedBookingId;

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
      final review = await _reviewService.getReview(
        selected.bookingId,
      );

      if (!mounted) return;

      setState(() {
        if (review != null) {
          _selectedRating = review.rating;
          _reviewController.text = review.comment;
          _hasExistingReview = true;
        }

        _loadedBookingId = selected.bookingId;
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to load review: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
        });
      }
    }
  }

  Future<void> _selectEquipment(
    ReviewEquipmentOption equipment,
  ) async {
    setState(() {
      _selectedEquipment = equipment;
    });

    if (_loadedBookingId != equipment.bookingId) {
      await _loadReview();
    }
  }

  Future<void> _saveReview() async {
    final ReviewEquipmentOption? selected = _selectedEquipment;

    if (selected == null) {
      _showMessage(
        'Please select completed equipment.',
      );
      return;
    }

    if (_selectedRating == 0) {
      _showMessage(
        'Please select a star rating.',
      );
      return;
    }

    final String comment = _reviewController.text.trim();

    if (comment.isEmpty) {
      _showMessage(
        'Please write a short review.',
      );
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
        _loadedBookingId = selected.bookingId;
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

      _showMessage(
        'Unable to save review: $error',
      );
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
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
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
                style: TextStyle(
                  color: darkText,
                ),
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
      await _reviewService.deleteReview(
        selected.bookingId,
      );

      if (!mounted) return;

      setState(() {
        _selectedRating = 0;
        _reviewController.clear();
        _hasExistingReview = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Review deleted successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to delete review: $error',
      );
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
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _prepareInitialSelection(
    List<ReviewEquipmentOption> rentals,
  ) {
    if (rentals.isEmpty) {
      return;
    }

    if (_selectedEquipment == null) {
      _selectedEquipment = rentals.first;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _loadedBookingId != rentals.first.bookingId) {
          _loadReview();
        }
      });

      return;
    }

    final bool stillExists = rentals.any(
      (item) =>
          item.bookingId == _selectedEquipment!.bookingId,
    );

    if (!stillExists) {
      _selectedEquipment = rentals.first;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadReview();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewEquipmentOption>>(
      stream: _completedRentalService.watchCompletedRentals(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryRed,
              ),
            ),
          );
        }

        final List<ReviewEquipmentOption> rentals =
            snapshot.data ?? [];

        if (rentals.isEmpty) {
          return _buildEmptyScreen();
        }

        _prepareInitialSelection(rentals);

        return _buildMainScreen(rentals);
      },
    );
  }

  Widget _buildMainScreen(
    List<ReviewEquipmentOption> rentals,
  ) {
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
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroCard(),

                  const SizedBox(height: 24),

                  const Text(
                    'Completed rental',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildEquipmentSelector(rentals),

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
                    enabled: !_isLoadingReview &&
                        !_isSaving &&
                        !_isDeleting,
                    minLines: 5,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          'Example: Equipment was in good condition and the provider was helpful...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(16),
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
                        borderRadius:
                            BorderRadius.circular(14),
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
                      onPressed: _isSaving ||
                              _isLoadingReview ||
                              _isDeleting
                          ? null
                          : _saveReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            primaryRed.withValues(
                          alpha: 0.55,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.star_rounded,
                            ),
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
                        onPressed:
                            _isDeleting || _isSaving
                                ? null
                                : _deleteReview,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryRed,
                          side: const BorderSide(
                            color: primaryRed,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
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
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
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
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSelector(
    List<ReviewEquipmentOption> rentals,
  ) {
    final ReviewEquipmentOption? selected =
        _selectedEquipment;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showEquipmentPicker(rentals);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.sports_rounded,
                  color: Color(0xFF3478C7),
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected?.equipmentName ??
                          'Select equipment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (selected != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Completed ${selected.rentedDate}',
                        style: const TextStyle(
                          color: greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: greyText,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEquipmentPicker(
    List<ReviewEquipmentOption> rentals,
  ) async {
    final ReviewEquipmentOption? selected =
        await showModalBottomSheet<ReviewEquipmentOption>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              4,
              18,
              22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select completed rental',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose the equipment you want to review.',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 18),

                ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxHeight: 400,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: rentals.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = rentals[index];

                      final bool isSelected =
                          item.bookingId ==
                              _selectedEquipment
                                  ?.bookingId;

                      return InkWell(
                        borderRadius:
                            BorderRadius.circular(15),
                        onTap: () {
                          Navigator.pop(
                            bottomSheetContext,
                            item,
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFFFFF1F3,
                                  )
                                : const Color(
                                    0xFFF8F8F8,
                                  ),
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? primaryRed
                                  : borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                    0xFFEDF4FF,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .sports_rounded,
                                  color: Color(
                                    0xFF3478C7,
                                  ),
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
                                    Text(
                                      item.equipmentName,
                                      style:
                                          const TextStyle(
                                        color:
                                            darkText,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      'Completed ${item.rentedDate}',
                                      style:
                                          const TextStyle(
                                        color:
                                            greyText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color: primaryRed,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await _selectEquipment(selected);
    }
  }

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        22,
        18,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
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
              color: _selectedRating == 0
                  ? greyText
                  : starColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          if (_isLoadingReview)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: CircularProgressIndicator(
                color: primaryRed,
              ),
            )
          else
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) {
                  final int value = index + 1;

                  final bool selected =
                      value <= _selectedRating;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(50),
                    onTap: () {
                      setState(() {
                        _selectedRating = value;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons
                                .star_border_rounded,
                        size: 43,
                        color: selected
                            ? starColor
                            : const Color(
                                0xFFD2D2D2,
                              ),
                      ),
                    ),
                  );
                },
              ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor:
                    Color(0xFFFFEEF1),
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
                style: TextStyle(
                  color: greyText,
                  fontSize: 13,
                  height: 1.5,
                ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: primaryRed,
                size: 52,
              ),
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