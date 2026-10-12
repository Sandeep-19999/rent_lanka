// SDK doubles never access live Firebase data.
// ignore_for_file: subtype_of_sealed_class
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/profile_service.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/edit_profile_screen.dart';
import 'package:rent_lanka_mobile/features/provider/services/cloudinary_service.dart';
import 'package:rent_lanka_mobile/features/user_discovery/services/user_service.dart';

class ProfileUser extends Fake implements User {
  @override
  String get uid => 'current-user';
  @override
  String get displayName => 'Old Auth name';
  @override
  String get email => 'original@example.com';
  @override
  String? get phoneNumber => null;
}

class ProfileAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser = ProfileUser();
}

class ProfileDocument extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  ProfileDocument(this.values);
  final Map<String, dynamic>? values;
  @override
  bool get exists => values != null;
  @override
  Map<String, dynamic>? data() => values == null ? null : Map.of(values!);
}

class ProfileStore extends Fake implements FirebaseFirestore {
  Map<String, dynamic>? values = {
    'name': 'Saved name',
    'email': 'original@example.com',
    'phone': '0771234567',
    'location': 'Colombo',
    'role': 'provider',
    'createdAt': 'original',
    'photoUrl': 'https://example.com/old.jpg',
  };
  Object? failure;
  VoidCallback? afterRead;
  String? path;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'users');
    return ProfileCollection(this);
  }

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async => handler(ProfileTransaction(this));
}

class ProfileCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  ProfileCollection(this.store);
  final ProfileStore store;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    store.path = 'users/$path';
    return ProfileReference(store);
  }
}

class ProfileReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  ProfileReference(this.store);
  final ProfileStore store;
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    final snapshot = ProfileDocument(store.values);
    store.afterRead?.call();
    return snapshot;
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    if (store.failure != null) throw store.failure!;
    store.values!.addAll(Map<String, dynamic>.from(data));
  }
}

class ProfileTransaction extends Fake implements Transaction {
  ProfileTransaction(this.store);
  final ProfileStore store;
  @override
  Future<DocumentSnapshot<T>> get<T>(DocumentReference<T> reference) async =>
      ProfileDocument(store.values) as DocumentSnapshot<T>;
  @override
  Transaction set<T>(
    DocumentReference<T> reference,
    T data, [
    SetOptions? options,
  ]) {
    store.values ??= {};
    store.values!.addAll(Map<String, dynamic>.from(data as Map));
    return this;
  }
}

class ProfileCloudinary extends Fake implements CloudinaryService {
  @override
  Future<CloudinaryUploadResult> uploadImage(
    Uint8List bytes, {
    required String filename,
  }) async => const CloudinaryUploadResult(
    secureUrl: 'https://res.cloudinary.com/gg8wheuw/image/upload/new.jpg',
    publicId: 'new',
  );
}

Future<void> save(
  ProfileService service, {
  String name = ' Updated name ',
  String? photoUrl,
  String? photoPublicId,
}) => service.saveProfile(
  name: name,
  email: 'original@example.com',
  phone: ' 0779999999 ',
  location: ' Kandy ',
  photoUrl: photoUrl,
  photoPublicId: photoPublicId,
  expectedUserId: 'current-user',
);

void main() {
  test('partial profile save persists actual fields without overwriting role, email, creation or old photo', () async {
    final store = ProfileStore();
    final auth = ProfileAuth();
    final service = ProfileService(
      firestore: store,
      auth: auth,
      cloudinary: ProfileCloudinary(),
    );
    await save(service);
    expect(store.path, 'users/current-user');
    expect(store.values!['name'], 'Updated name');
    expect(store.values!['phone'], '0779999999');
    expect(store.values!['location'], 'Kandy');
    expect(store.values!['role'], 'provider');
    expect(store.values!['email'], 'original@example.com');
    expect(store.values!['createdAt'], 'original');
    expect(store.values!['photoUrl'], 'https://example.com/old.jpg');
    expect(
      (await ProfileService(
        firestore: store,
        auth: auth,
      ).getProfile()).data()!['name'],
      'Updated name',
    );
  });
  test(
    'Cloudinary URL and public ID persist in existing photo fields',
    () async {
      final store = ProfileStore();
      final service = ProfileService(
        firestore: store,
        auth: ProfileAuth(),
        cloudinary: ProfileCloudinary(),
      );
      final result = await service.uploadProfilePhoto(
        imageBytes: Uint8List.fromList([1]),
        fileName: 'photo.jpg',
      );
      await save(
        service,
        photoUrl: result.secureUrl,
        photoPublicId: result.publicId,
      );
      expect(store.values!['photoUrl'], result.secureUrl);
      expect(store.values!['photoPublicId'], 'new');
    },
  );
  test('blank names, signed-out sessions, account switches and write failures are reported', () async {
    final store = ProfileStore();
    final auth = ProfileAuth();
    final service = ProfileService(firestore: store, auth: auth);
    await expectLater(save(service, name: '   '), throwsArgumentError);
    auth.currentUser = null;
    await expectLater(save(service), throwsStateError);
    auth.currentUser = ProfileUser();
    store.afterRead = () => auth.currentUser = null;
    await expectLater(save(service), throwsStateError);
    expect(store.values!['name'], 'Saved name');
    store.afterRead = null;
    auth.currentUser = ProfileUser();
    store.failure = StateError('offline');
    await expectLater(save(service), throwsStateError);
    expect(store.values!['name'], 'Saved name');
  });
  test('role selection preserves saved profile instead of restoring stale Auth values', () async {
    final store = ProfileStore();
    await UserService(
      firestore: store,
      auth: ProfileAuth(),
    ).saveUserRole('player');
    expect(store.values!['role'], 'player');
    expect(store.values!['name'], 'Saved name');
    expect(store.values!['phone'], '0771234567');
    expect(store.values!['email'], 'original@example.com');
  });
  testWidgets(
    'Edit Profile saves trimmed fields and reopening loads persisted values',
    (tester) async {
      final store = ProfileStore();
      final service = ProfileService(firestore: store, auth: ProfileAuth());
      await tester.pumpWidget(
        MaterialApp(home: EditProfileScreen(profileService: service)),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), ' New profile name ');
      await tester.enterText(fields.at(2), '0778888888');
      await tester.enterText(fields.at(3), ' Galle ');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(store.values!['name'], 'New profile name');
      expect(store.values!['phone'], '0778888888');
      expect(store.values!['location'], 'Galle');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(home: EditProfileScreen(profileService: service)),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        'New profile name',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(3)).controller!.text,
        'Galle',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
