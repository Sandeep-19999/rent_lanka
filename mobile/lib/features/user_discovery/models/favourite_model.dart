class FavouriteReference {
  const FavouriteReference(this.id, this.createdAt, {this.pending = false});
  final String id;
  final bool pending;
  final DateTime? createdAt;
}

List<String> orderedFavouriteIds(List<FavouriteReference> references) {
  final rows = List<FavouriteReference>.of(references)
    ..sort((a, b) {
      if (a.pending != b.pending) return a.pending ? -1 : 1;
      if (a.createdAt == null && b.createdAt != null) return 1;
      if (a.createdAt != null && b.createdAt == null) return -1;
      final dates = a.createdAt == null
          ? 0
          : b.createdAt!.compareTo(a.createdAt!);
      return dates != 0 ? dates : a.id.compareTo(b.id);
    });
  return rows.map((row) => row.id).toSet().toList();
}

class FavouriteEquipment {
  const FavouriteEquipment(this.id, {this.equipment, this.error});
  final String id;
  final Map<String, dynamic>? equipment;
  final Object? error;
}

List<FavouriteEquipment> groupFavouriteEquipment(
  List<FavouriteEquipment> rows,
) => [
  ...rows.where((row) => row.equipment != null && row.error == null),
  ...rows.where((row) => row.equipment == null || row.error != null),
];
