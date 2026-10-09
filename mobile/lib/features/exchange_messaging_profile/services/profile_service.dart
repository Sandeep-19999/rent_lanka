import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../provider/services/cloudinary_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CloudinaryService _cloudinary;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    CloudinaryService? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _cloudinary = cloudinary ?? CloudinaryService();

  String get currentUserId {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    throw StateError('Please log in to continue.');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile() async* {
    yield* _firestore.collection('users').doc(currentUserId).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() {
    return _firestore.collection('users').doc(currentUserId).get();
  }

  Future<CloudinaryUploadResult> uploadProfilePhoto({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final uid = currentUserId;
    final result = await _cloudinary.uploadImage(
      imageBytes,
      filename: fileName,
    );
    if (currentUserId != uid) {
      throw StateError('Your login changed. Please reopen Edit Profile.');
    }
    return result;
  }

  static Map<String, dynamic> photoChanges({
    String? photoUrl,
    String? photoPublicId,
  }) {
    if (photoUrl == null) return {};
    final uri = Uri.tryParse(photoUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError('The uploaded profile photo URL is invalid.');
    }
    return {'photoUrl': photoUrl, 'photoPublicId': ?photoPublicId};
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
    String? photoUrl,
    String? photoPublicId,
    required String expectedUserId,
  }) async {
    final uid = currentUserId;
    if (uid != expectedUserId) {
      throw StateError('Your login changed. Please reopen Edit Profile.');
    }
    final photos = photoChanges(
      photoUrl: photoUrl,
      photoPublicId: photoPublicId,
    );
    final DocumentReference<Map<String, dynamic>> documentReference = _firestore
        .collection('users')
        .doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> existing =
        await documentReference.get();

    final Map<String, dynamic> data = {
      'userId': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'location': location.trim(),
      ...photos,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['isVerified'] = true;
    }

    if (currentUserId != uid) {
      throw StateError('Your login changed. Please reopen Edit Profile.');
    }
    await documentReference.set(data, SetOptions(merge: true));
  }
}
