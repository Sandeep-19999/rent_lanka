import 'package:flutter/material.dart';

import '../../exchange_messaging_profile/models/review_model.dart';
import '../../exchange_messaging_profile/screens/rate_review_screen.dart';
import '../../exchange_messaging_profile/services/review_service.dart';

/// The existing equipment rating row, backed by the same reviews as its page.
class EquipmentRating extends StatefulWidget {
  const EquipmentRating({
    super.key,
    required this.equipmentId,
    required this.equipmentName,
    this.reviewService,
  });

  final String equipmentId;
  final String equipmentName;
  final ReviewService? reviewService;

  @override
  State<EquipmentRating> createState() => _EquipmentRatingState();
}

class _EquipmentRatingState extends State<EquipmentRating> {
  late ReviewService _service;
  late Stream<List<ReviewModel>> _reviews;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(EquipmentRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.equipmentId != widget.equipmentId ||
        oldWidget.reviewService != widget.reviewService) {
      _subscribe();
    }
  }

  void _subscribe() {
    _service = widget.reviewService ?? ReviewService();
    _reviews = widget.equipmentId.isEmpty
        ? Stream.value([])
        : _service.watchEquipmentReviews(widget.equipmentId);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<ReviewModel>>(
    key: ValueKey(widget.equipmentId),
    stream: _reviews,
    builder: (context, snapshot) {
      final average = ReviewService.averageRating(snapshot.data ?? []);
      final rating = snapshot.hasError
          ? 'Unavailable'
          : !snapshot.hasData
          ? '…'
          : average?.toStringAsFixed(1) ?? 'N/A';
      return InkWell(
        key: const ValueKey('equipment-rating'),
        borderRadius: BorderRadius.circular(5),
        onTap: widget.equipmentId.isEmpty
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => RateReviewScreen(
                    equipmentId: widget.equipmentId,
                    equipmentName: widget.equipmentName,
                    reviewService: _service,
                  ),
                ),
              ),
        child: Row(
          children: [
            const Text(
              'Equipment rating',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFA000),
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE99700),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
