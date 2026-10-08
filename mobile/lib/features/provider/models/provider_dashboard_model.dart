class ProviderDashboardModel {
  final int equipmentCount;

  final int pendingCount;
  final int acceptedCount;
  final int activeCount;
  final int completedCount;

  final double totalEarnings;
  final double withdrawalTotal;
  final double availableToWithdraw;

  const ProviderDashboardModel({
    required this.equipmentCount,
    required this.pendingCount,
    required this.acceptedCount,
    required this.activeCount,
    required this.completedCount,
    required this.totalEarnings,
    required this.withdrawalTotal,
    required this.availableToWithdraw,
  });

  const ProviderDashboardModel.empty()
      : equipmentCount = 0,
        pendingCount = 0,
        acceptedCount = 0,
        activeCount = 0,
        completedCount = 0,
        totalEarnings = 0,
        withdrawalTotal = 0,
        availableToWithdraw = 0;
}