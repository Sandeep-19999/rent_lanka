import 'dart:async';

import '../models/equipment_model.dart';
import '../models/provider_dashboard_model.dart';
import '../models/rental_request_model.dart';

import 'equipment_service.dart';
import 'rental_request_service.dart';
import 'withdrawal_service.dart';

class ProviderDashboardService {
  final EquipmentService _equipmentService;
  final RentalRequestService _rentalRequestService;
  final WithdrawalService _withdrawalService;

  ProviderDashboardService({
    EquipmentService? equipmentService,
    RentalRequestService? rentalRequestService,
    WithdrawalService? withdrawalService,
  })  : _equipmentService =
            equipmentService ?? EquipmentService(),
        _rentalRequestService =
            rentalRequestService ??
                RentalRequestService(),
        _withdrawalService =
            withdrawalService ??
                WithdrawalService();

  Stream<ProviderDashboardModel>
      watchDashboard() {
    late StreamController<
        ProviderDashboardModel> controller;

    StreamSubscription<List<EquipmentModel>>?
        equipmentSubscription;

    StreamSubscription<List<RentalRequestModel>>?
        requestSubscription;

    StreamSubscription<double>?
        withdrawalSubscription;

    List<EquipmentModel>? equipment;
    List<RentalRequestModel>? requests;
    double? withdrawalTotal;

    void emitDashboard() {
      if (equipment == null ||
          requests == null ||
          withdrawalTotal == null ||
          controller.isClosed) {
        return;
      }

      int pendingCount = 0;
      int acceptedCount = 0;
      int activeCount = 0;
      int completedCount = 0;

      double totalEarnings = 0;

      for (final request in requests!) {
        switch (request.status) {
          case 'pending':
            pendingCount++;
            break;

          case 'accepted':
            acceptedCount++;
            break;

          case 'active':
            activeCount++;
            break;

          case 'completed':
            completedCount++;
            totalEarnings +=
                request.totalAmount;
            break;
        }
      }

      double availableToWithdraw =
          totalEarnings - withdrawalTotal!;

      if (availableToWithdraw < 0) {
        availableToWithdraw = 0;
      }

      controller.add(
        ProviderDashboardModel(
          equipmentCount:
              equipment!.length,
          pendingCount: pendingCount,
          acceptedCount: acceptedCount,
          activeCount: activeCount,
          completedCount:
              completedCount,
          totalEarnings:
              totalEarnings,
          withdrawalTotal:
              withdrawalTotal!,
          availableToWithdraw:
              availableToWithdraw,
        ),
      );
    }

    controller =
        StreamController<
            ProviderDashboardModel>(
      onListen: () {
        equipmentSubscription =
            _equipmentService
                .watchMyEquipment()
                .listen(
          (items) {
            equipment = items;
            emitDashboard();
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(
                error,
              );
            }
          },
        );

        requestSubscription =
            _rentalRequestService
                .watchMyRentalRequests()
                .listen(
          (items) {
            requests = items;
            emitDashboard();
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(
                error,
              );
            }
          },
        );

        withdrawalSubscription =
            _withdrawalService
                .watchWithdrawalTotal()
                .listen(
          (value) {
            withdrawalTotal =
                value;
            emitDashboard();
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(
                error,
              );
            }
          },
        );
      },

      onCancel: () async {
        await equipmentSubscription
            ?.cancel();

        await requestSubscription
            ?.cancel();

        await withdrawalSubscription
            ?.cancel();
      },
    );

    return controller.stream;
  }
}