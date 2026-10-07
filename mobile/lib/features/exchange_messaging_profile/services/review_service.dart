import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    // Temporary preview/testing fallback.
    // rental_requests currently use demo_player.
    return 'demo_player';
  }

  String _reviewDocumentId(String bookingId) {
    return '${currentUserId}_$bookingId';
  }

  Future<ReviewModel?> getReview(String bookingId) async {
    final document = await _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId))
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return ReviewModel(
      id: document.id,
      reviewerId: data['reviewerId']?.toString() ?? '',
      providerId: data['providerId']?.toString() ?? '',
      equipmentId: data['equipmentId']?.toString() ?? '',
      bookingId: data['bookingId']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Future<void> saveReview({
    required String providerId,
    required String equipmentId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    final String cleanComment = comment.trim();

    if (cleanComment.isEmpty) {
      throw Exception('Review comment cannot be empty.');
    }

    final reference = _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId));

    final existingDocument = await reference.get();

    final Map<String, dynamic> reviewData = {
      'reviewerId': currentUserId,
      'providerId': providerId,
      'equipmentId': equipmentId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': cleanComment,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existingDocument.exists) {
      reviewData['createdAt'] = FieldValue.serverTimestamp();
    }

    await reference.set(reviewData, SetOptions(merge: true));
  }

  Future<void> deleteReview(String bookingId) async {
    final reference = _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId));

    await reference.delete();
  }
}
