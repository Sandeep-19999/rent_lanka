import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/features/provider/models/bank_account_model.dart';
import 'package:rent_lanka_mobile/features/provider/models/withdrawal_model.dart';
import 'package:rent_lanka_mobile/features/provider/models/withdrawal_request.dart';
import 'package:rent_lanka_mobile/features/provider/screens/withdrawal_history_screen.dart';

const bank = BankAccountModel(
  id: 'bank',
  providerId: 'provider',
  bankName: 'Test Bank',
  accountHolderName: 'Provider',
  accountNumber: '001234',
  branch: 'Colombo',
  isDefault: true,
  createdAt: null,
);

void main() {
  Map<String, dynamic> request({
    double amount = 12000,
    String uid = 'provider',
  }) => WithdrawalRequest.toFirestore(
    providerId: uid,
    bankAccount: bank,
    amount: amount,
    requestedAt: 'SERVER_TIMESTAMP',
  );

  test('mobile submits pending only, without approval or payout fields', () {
    final data = request();
    expect(data['status'], 'pending');
    expect(data['amount'], 12000);
    expect(data['accountLast4'], '1234');
    expect(data['requestedAt'], 'SERVER_TIMESTAMP');
    expect(data.containsKey('approvedAt'), isFalse);
    expect(data.containsKey('approvedBy'), isFalse);
    expect(data.containsKey('approvalNote'), isFalse);
    expect(data.containsKey('accountNumber'), isFalse);
  });

  test(
    'invalid amounts and another provider bank are rejected before writing',
    () {
      for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
        expect(() => request(amount: amount), throwsArgumentError);
      }
      expect(() => request(uid: 'other'), throwsArgumentError);
    },
  );

  test('old pending records remain pending and approved records retain admin audit', () {
    final pending = WithdrawalModel.fromMap('request', request());
    expect(pending.status, 'pending');
    expect(pending.approvedAt, isNull);
    final approved = WithdrawalModel.fromMap('request', {
      ...request(),
      'status': 'approved',
      'approvedAt': Timestamp.fromDate(DateTime(2026, 10, 11, 14)),
      'approvalNote': 'Reviewed bank details.',
    });
    expect(approved.approvedAt, DateTime(2026, 10, 11, 14));
    expect(approved.statusDescription, contains('Awaiting bank payout'));
    expect(approved.approvalNote, 'Reviewed bank details.');
  });

  for (final status in ['pending', 'approved']) {
    testWidgets('history explains $status at a narrow phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final withdrawal = WithdrawalModel.fromMap('request', {
        ...request(),
        'status': status,
        if (status == 'approved') ...{
          'approvedAt': Timestamp.fromDate(DateTime(2026, 10, 11, 14)),
          'approvalNote': 'Reviewed bank details.',
        },
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: WithdrawalHistoryCard(withdrawal: withdrawal),
            ),
          ),
        ),
      );
      expect(find.text(withdrawal.statusDescription), findsOneWidget);
      expect(find.text(status.toUpperCase()), findsOneWidget);
      if (status == 'approved') {
        expect(find.text('Reviewed bank details.'), findsOneWidget);
        expect(find.textContaining('Approved: '), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
