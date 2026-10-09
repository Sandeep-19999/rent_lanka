import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

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

  Future<String> uploadProfilePhoto({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final String extension = _getFileExtension(fileName);

    final Reference storageReference = _storage
        .ref()
        .child('profile_photos')
        .child(currentUserId)
        .child('profile.$extension');

    final String contentType = _getContentType(extension);

    final UploadTask uploadTask = storageReference.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    final TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
    required String photoUrl,
  }) async {
    final DocumentReference<Map<String, dynamic>> documentReference = _firestore
        .collection('users')
        .doc(currentUserId);

    final DocumentSnapshot<Map<String, dynamic>> existing =
        await documentReference.get();

    final Map<String, dynamic> data = {
      'userId': currentUserId,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'location': location.trim(),
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['isVerified'] = true;
    }

    await documentReference.set(data, SetOptions(merge: true));
  }

  String _getFileExtension(String fileName) {
    final List<String> parts = fileName.split('.');

    if (parts.length < 2) {
      return 'jpg';
    }

    final String extension = parts.last.toLowerCase();

    if (extension == 'png' ||
        extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'webp') {
      return extension;
    }

    return 'jpg';
  }

  String _getContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
