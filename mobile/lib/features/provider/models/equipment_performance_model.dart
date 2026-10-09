class EquipmentPerformanceItem {
  final String equipmentId;
  final String name;
  final int rentals;
  final double revenue;

  const EquipmentPerformanceItem({
    required this.equipmentId,
    required this.name,
    required this.rentals,
    required this.revenue,
  });
}

class EquipmentPerformanceModel {
  final int equipmentCount;
  final int completedRentals;
  final int activeRentals;
  final double totalRevenue;

  final List<EquipmentPerformanceItem> topEquipment;

  const EquipmentPerformanceModel({
    required this.equipmentCount,
    required this.completedRentals,
    required this.activeRentals,
    required this.totalRevenue,
    required this.topEquipment,
  });

  const EquipmentPerformanceModel.empty()
      : equipmentCount = 0,
        completedRentals = 0,
        activeRentals = 0,
        totalRevenue = 0,
        topEquipment = const [];
}