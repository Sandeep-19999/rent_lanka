import 'dart:async';

import '../models/equipment_model.dart';
import '../models/equipment_performance_model.dart';
import '../models/rental_request_model.dart';

import 'equipment_service.dart';
import 'rental_request_service.dart';

class EquipmentPerformanceService {
  final EquipmentService _equipmentService;
  final RentalRequestService _rentalRequestService;

  EquipmentPerformanceService({
    EquipmentService? equipmentService,
    RentalRequestService? rentalRequestService,
  })  : _equipmentService =
            equipmentService ?? EquipmentService(),
        _rentalRequestService =
            rentalRequestService ?? RentalRequestService();

  Stream<EquipmentPerformanceModel>
      watchPerformance() {
    late StreamController<
        EquipmentPerformanceModel> controller;

    StreamSubscription<List<EquipmentModel>>?
        equipmentSubscription;

    StreamSubscription<List<RentalRequestModel>>?
        rentalSubscription;

    List<EquipmentModel>? equipment;
    List<RentalRequestModel>? requests;

    void emitPerformance() {
      if (equipment == null ||
          requests == null ||
          controller.isClosed) {
        return;
      }

      controller.add(
        _calculatePerformance(
          equipment!,
          requests!,
        ),
      );
    }

    controller =
        StreamController<EquipmentPerformanceModel>(
      onListen: () {
        equipmentSubscription =
            _equipmentService
                .watchMyEquipment()
                .listen(
          (items) {
            equipment = items;
            emitPerformance();
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );

        rentalSubscription =
            _rentalRequestService
                .watchMyRentalRequests()
                .listen(
          (items) {
            requests = items;
            emitPerformance();
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );
      },
      onCancel: () async {
        await equipmentSubscription?.cancel();
        await rentalSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  EquipmentPerformanceModel _calculatePerformance(
    List<EquipmentModel> equipment,
    List<RentalRequestModel> requests,
  ) {
    final int equipmentCount =
        equipment.length;

    int completedRentals = 0;
    int activeRentals = 0;

    double totalRevenue = 0;

    final Map<String, _MutableEquipmentStats>
        stats = {};

    // Current provider equipment.
    for (final item in equipment) {
      stats[item.id] = _MutableEquipmentStats(
        equipmentId: item.id,
        name: item.name.isEmpty
            ? 'Equipment'
            : item.name,
      );
    }

    // Rental performance.
    for (final request in requests) {
      if (request.status == 'active') {
        activeRentals++;
      }

      if (request.status != 'completed') {
        continue;
      }

      completedRentals++;

      totalRevenue += request.totalAmount;

      final String equipmentId =
          request.equipmentId;

      if (!stats.containsKey(equipmentId)) {
        stats[equipmentId] =
            _MutableEquipmentStats(
          equipmentId: equipmentId,
          name: request.equipmentName.isEmpty
              ? 'Equipment'
              : request.equipmentName,
        );
      }

      final item = stats[equipmentId];

      if (item != null) {
        item.rentals++;
        item.revenue +=
            request.totalAmount;
      }
    }

    final List<_MutableEquipmentStats>
        ranked =
        stats.values
            .where(
              (item) => item.rentals > 0,
            )
            .toList()
          ..sort(
            (a, b) => b.rentals.compareTo(
              a.rentals,
            ),
          );

    final List<EquipmentPerformanceItem>
        topEquipment =
        ranked
            .take(3)
            .map(
              (item) =>
                  EquipmentPerformanceItem(
                equipmentId:
                    item.equipmentId,
                name: item.name,
                rentals: item.rentals,
                revenue: item.revenue,
              ),
            )
            .toList();

    return EquipmentPerformanceModel(
      equipmentCount: equipmentCount,
      completedRentals:
          completedRentals,
      activeRentals: activeRentals,
      totalRevenue: totalRevenue,
      topEquipment: topEquipment,
    );
  }
}

class _MutableEquipmentStats {
  final String equipmentId;
  final String name;

  int rentals;
  double revenue;

  _MutableEquipmentStats({
    required this.equipmentId,
    required this.name,
    this.rentals = 0,
    this.revenue = 0,
  });
}