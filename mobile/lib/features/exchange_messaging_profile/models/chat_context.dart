import 'dart:convert';

/// Optional context metadata; old user-pair chats need no context fields.
class ChatContext {
  final String equipmentName;
  final String contextType;

  const ChatContext({this.equipmentName = '', this.contextType = ''});

  factory ChatContext.fromData(Map<String, dynamic> data) => ChatContext(
    equipmentName: data['equipmentName']?.toString().trim() ?? '',
    contextType: data['contextType']?.toString().trim() ?? '',
  );

  String get label {
    if (equipmentName.isEmpty) return '';
    final typeLabel = switch (contextType) {
      'rental_request' => 'Rental Request',
      'exchange_request' || 'exchange' => 'Exchange Request',
      _ => '',
    };
    return typeLabel.isEmpty ? equipmentName : '$equipmentName • $typeLabel';
  }

  static String rentalChatId({
    required String providerId,
    required String playerId,
    required String requestId,
  }) {
    if ([providerId, playerId, requestId].any((id) => id.trim().isEmpty) ||
        providerId == playerId) {
      throw ArgumentError('Valid provider, player and request IDs are required.');
    }
    // Encoding the tuple avoids separator collisions and Firestore path slashes.
    final key = base64Url.encode(utf8.encode(jsonEncode(
      [providerId, playerId, requestId],
    ))).replaceAll('=', '');
    return 'rental_request_$key';
  }
}
