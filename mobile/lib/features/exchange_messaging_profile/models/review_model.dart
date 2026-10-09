import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String reviewerId;
  final String providerId;
  final String equipmentId;
  final String bookingId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.providerId,
    required this.equipmentId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final createdTimestamp = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
        : null;

    final updatedTimestamp = data['updatedAt'] is Timestamp
        ? data['updatedAt'] as Timestamp
        : null;

    return ReviewModel(
      id: document.id,
      reviewerId: data['reviewerId']?.toString() ?? '',
      providerId: data['providerId']?.toString() ?? '',
      equipmentId: data['equipmentId']?.toString() ?? '',
      bookingId: data['bookingId']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment']?.toString() ?? '',
      createdAt: createdTimestamp?.toDate(),
      updatedAt: updatedTimestamp?.toDate(),
    );
  }
}
