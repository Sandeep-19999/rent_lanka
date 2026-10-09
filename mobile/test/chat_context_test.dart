import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/models/chat_context.dart';

void main() {
  String id(String request, {String provider = 'provider', String player = 'player'}) =>
    ChatContext.rentalChatId(providerId: provider, playerId: player, requestId: request);

  test('same rental request reuses its deterministic chat ID', () {
    expect(id('fan-request'), id('fan-request'));
  });
  test('different requests and participants remain separate', () {
    expect(id('fan-request'), isNot(id('bat-request')));
    expect(id('fan-request'), isNot(id('fan-request', provider: 'another')));
    expect(id('fan-request'), isNot(id('fan-request', player: 'another')));
  });
  test('tuple encoding avoids delimiter collisions and path separators', () {
    expect(id('request', provider: 'a_b', player: 'c'),
      isNot(id('request', provider: 'a', player: 'b_c')));
    expect(id('request/17'), isNot(contains('/')));
  });
  test('legacy chats omit equipment context', () {
    expect(ChatContext.fromData({'lastMessage': 'Hello'}).label, isEmpty);
    expect(ChatContext.fromData({'contextType': 'rental_request'}).label, isEmpty);
  });
  test('equipment labels respect rental and exchange contexts', () {
    expect(ChatContext.fromData({'equipmentName': 'fan',
      'contextType': 'rental_request'}).label, 'fan • Rental Request');
    expect(ChatContext.fromData({'equipmentName': 'bat',
      'contextType': 'exchange_request'}).label, 'bat • Exchange Request');
    expect(ChatContext.fromData({'equipmentName': 'fan'}).label, 'fan');
  });
  test('invalid participants and missing requests are rejected', () {
    expect(() => id(''), throwsArgumentError);
    expect(() => id('request', player: 'provider'), throwsArgumentError);
  });
}
