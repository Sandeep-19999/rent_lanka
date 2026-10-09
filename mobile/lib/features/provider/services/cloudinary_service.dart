import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> data) {
    final url = data['secure_url'];
    final id = data['public_id'];
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        id is! String ||
        id.trim().isEmpty) {
      throw const FormatException(
        'Cloudinary returned an invalid image response.',
      );
    }
    return CloudinaryUploadResult(secureUrl: url as String, publicId: id);
  }
}

/// Only standard unsigned Cloudinary image URLs are transformed.
String equipmentThumbnailUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.host != 'res.cloudinary.com' ||
      !['http', 'https'].contains(uri.scheme)) {
    return url;
  }
  final segments = uri.pathSegments;
  if (segments.length < 4 ||
      segments[1] != 'image' ||
      segments[2] != 'upload' ||
      segments[3].startsWith('s--')) {
    return url;
  }
  const marker = '/image/upload/';
  return url.replaceFirst(marker, '${marker}f_auto,q_auto,w_400,c_limit/');
}

class CloudinaryService {
  Future<CloudinaryUploadResult> uploadImage(
    Uint8List bytes, {
    required String filename,
  }) async {
    if (bytes.isEmpty) throw ArgumentError('Please select a photo first.');
    final client = http.Client();
    try {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse(
                'https://api.cloudinary.com/v1_1/gg8wheuw/image/upload',
              ),
            )
            ..fields['upload_preset'] = 'rent_lanka_equipment'
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: filename),
            );
      final response = await (() async {
        final streamed = await client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(const Duration(seconds: 60));
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw Exception(
          'Cloudinary returned an invalid response (HTTP ${response.statusCode}).',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded is Map ? decoded['error'] : null;
        final message = error is Map ? error['message'] : null;
        throw Exception(
          'Photo upload failed (HTTP ${response.statusCode})${message == null ? '.' : ': $message'}',
        );
      }
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Cloudinary returned an invalid image response.',
        );
      }
      return CloudinaryUploadResult.fromJson(decoded);
    } on TimeoutException {
      throw Exception(
        'Photo upload timed out. Check your internet connection and try again.',
      );
    } on http.ClientException {
      throw Exception(
        'Unable to upload photo. Check your internet connection and try again.',
      );
    } finally {
      client.close();
    }
  }
}
