import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/provider/models/rental_request_model.dart';

void main() {
  test('request exposes the actual player ID and retains provider fields', () {
    final request = RentalRequestModel.fromData('request-17', {
      'playerId': 'player-account',
      'playerName': 'Request player',
      'providerId': 'provider-account',
      'equipmentId': 'equipment-17',
      'totalAmount': 3000,
      'status': 'accepted',
      'reservedDates': ['2026-10-20'],
    });
    expect(request.playerId, 'player-account');
    expect(request.playerName, 'Request player');
    expect(request.providerId, 'provider-account');
    expect(request.equipmentId, 'equipment-17');
    expect(request.totalAmount, 3000);
    expect(request.status, 'accepted');
    expect(request.reservedDates, ['2026-10-20']);
  });
  test('legacy request has no fabricated player ID', () {
    final request = RentalRequestModel.fromData('request-17', {});
    expect(request.playerId, isEmpty);
  });
}
