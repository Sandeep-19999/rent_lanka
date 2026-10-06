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

    // Temporary preview fallback.
    return 'demo_member3_user';
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

    return ReviewModel.fromDocument(document);
  }

  Future<void> saveReview({
    required String providerId,
    required String equipmentId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final documentReference = _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId));

    final existing = await documentReference.get();

    final data = <String, dynamic>{
      'reviewerId': currentUserId,
      'providerId': providerId,
      'equipmentId': equipmentId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await documentReference.set(data, SetOptions(merge: true));
  }

  Future<void> deleteReview(String bookingId) async {
    await _firestore
        .collection('reviews')
        .doc(_reviewDocumentId(bookingId))
        .delete();
  }
}
