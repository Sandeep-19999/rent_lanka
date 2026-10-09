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

    throw StateError('Please log in to continue.');
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

    final uid = currentUserId;
    final reference = _firestore.collection('reviews').doc('${uid}_$bookingId');
    await _firestore.runTransaction((transaction) async {
      final rental = await transaction.get(_firestore.collection('rental_requests').doc(bookingId));
      final existing = await transaction.get(reference);
      if (currentUserId != uid) throw StateError('Please log in again.');
      final data = rental.data() ?? {};
      if (!canReview(data, uid) || data['equipmentId'] != equipmentId ||
          data['providerId'] != providerId) {
        throw Exception('Only your completed rental can be reviewed.');
      }
      transaction.set(reference, {
        'reviewerId': uid, 'providerId': providerId, 'equipmentId': equipmentId,
        'bookingId': bookingId, 'rating': rating, 'comment': cleanComment,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static bool canReview(Map<String, dynamic> rental, String uid) =>
      uid.isNotEmpty && rental['playerId'] == uid && rental['status']?.toString().trim().toLowerCase() == 'completed';

  Future<void> deleteReview(String bookingId) async {
    final reference = _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId));

    await reference.delete();
  }
}
