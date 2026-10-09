import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/utils/resubscribable_stream.dart';

void main() {
  test('tabs can cancel and listen again to the same stream', () async {
    var opened = 0;
    var cancelled = 0;
    final stream = resubscribableStream<int>(() {
      opened++;
      return StreamController<int>(onListen: () {}, onCancel: () => cancelled++).stream;
    });
    for (var i = 0; i < 5; i++) {
      final sub = stream.listen((_) {});
      await sub.cancel();
    }
    expect(opened, 5);
    expect(cancelled, 5);
  });
  test('each listener receives current data after a previous listener completed', () async {
    var value = 0;
    final stream = resubscribableStream(() => Stream.value(++value));
    expect(await stream.first, 1);
    expect(await stream.first, 2);
  });
  test('authentication/query setup errors are delivered to the UI on each listen', () async {
    final stream = resubscribableStream<int>(() => throw StateError('Login required'));
    await expectLater(stream.first, throwsStateError);
    await expectLater(stream.first, throwsStateError);
  });
}
