import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String photoUrl;
  final bool isVerified;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.photoUrl,
    required this.isVerified,
  });

  factory UserProfileModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return UserProfileModel.fromData(document.id, document.data() ?? {});
  }

  factory UserProfileModel.fromData(String id, Map<String, dynamic> data) {
    return UserProfileModel(
      id: id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      isVerified: data['isVerified'] == true,
    );
  }
}
