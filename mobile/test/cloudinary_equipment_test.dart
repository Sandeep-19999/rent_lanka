import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/provider/services/cloudinary_service.dart';
import 'package:rent_lanka_mobile/features/provider/models/equipment_model.dart';

void main() {
  test('valid upload retains secure URL and public ID', () {
    final result = CloudinaryUploadResult.fromJson({
      'secure_url':
          'https://res.cloudinary.com/gg8wheuw/image/upload/v1/bat.jpg',
      'public_id': 'bat',
    });
    expect(result.publicId, 'bat');
    expect(result.secureUrl, startsWith('https://'));
  });
  test('invalid upload responses are rejected', () {
    for (final data in <Map<String, dynamic>>[
      {},
      {'secure_url': 'http://example.com/a', 'public_id': 'a'},
      {'secure_url': 'https://example.com/a'},
      {'secure_url': 123, 'public_id': 'a'},
    ]) {
      expect(
        () => CloudinaryUploadResult.fromJson(data),
        throwsFormatException,
      );
    }
  });
  test('thumbnail retains version, folders, query and original', () {
    const url =
        'https://res.cloudinary.com/gg8wheuw/image/upload/v123/folder/bat.jpg?x=1';
    expect(
      equipmentThumbnailUrl(url),
      'https://res.cloudinary.com/gg8wheuw/image/upload/f_auto,q_auto,w_400,c_limit/v123/folder/bat.jpg?x=1',
    );
  });
  test('legacy and signed URLs remain unchanged', () {
    for (final url in [
      '',
      'https://firebasestorage.googleapis.com/v0/b/image',
      'https://example.com/photo.jpg',
      'https://res.cloudinary.com.evil.com/a/image/upload/a',
      'https://res.cloudinary.com/cloud/image/upload/s--signature--/v1/a.jpg',
    ]) {
      expect(equipmentThumbnailUrl(url), url);
    }
  });
  test('old equipment parses without image metadata', () {
    final model = EquipmentModel.fromData('old', {
      'name': 'Bat',
      'imageUrl': 'https://example.com/bat.jpg',
    });
    expect(model.imagePublicId, isNull);
    expect(model.imageUrl, 'https://example.com/bat.jpg');
    expect(model.toFirestore().containsKey('imagePublicId'), isFalse);
  });
  test('new equipment retains image metadata on copy and serialization', () {
    final model = EquipmentModel.fromData('new', {
      'imagePublicId': 'folder/bat',
    });
    expect(
      model.copyWith(name: 'Bat').toFirestore()['imagePublicId'],
      'folder/bat',
    );
  });
}
