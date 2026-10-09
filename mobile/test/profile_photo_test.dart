import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/user_profile_model.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/services/profile_service.dart';

void main() {
  test('old users retain default empty avatar URL', () {
    expect(UserProfileModel.fromData('uid', {'name': 'Player'}).photoUrl, '');
  });
  test('both roles use the same saved photo field', () {
    for (final role in ['player', 'provider']) {
      final profile = UserProfileModel.fromData('uid', {
        'role': role,
        'photoUrl': 'https://example.com/avatar.jpg',
      });
      expect(profile.photoUrl, 'https://example.com/avatar.jpg');
    }
  });
  test('text-only save leaves previous photo untouched', () {
    final old = {
      'photoUrl': 'https://example.com/old.jpg',
      'photoPublicId': 'old',
    };
    expect({...old, ...ProfileService.photoChanges()}, old);
  });
  test('invalid photo cannot overwrite old profile photo', () {
    expect(
      () => ProfileService.photoChanges(photoUrl: ''),
      throwsArgumentError,
    );
    expect(
      () => ProfileService.photoChanges(photoUrl: 'invalid'),
      throwsArgumentError,
    );
  });
  test('successful upload stores URL and public ID only', () {
    expect(
      ProfileService.photoChanges(
        photoUrl: 'https://res.cloudinary.com/gg8wheuw/image/upload/avatar.jpg',
        photoPublicId: 'avatar',
      ),
      {
        'photoUrl':
            'https://res.cloudinary.com/gg8wheuw/image/upload/avatar.jpg',
        'photoPublicId': 'avatar',
      },
    );
  });
}
