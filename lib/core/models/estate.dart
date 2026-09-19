class Estate {
  final String id;
  final String name;
  final String location;
  final String code;
  final int unitsCount;

  const Estate({
    required this.id,
    required this.name,
    required this.location,
    required this.code,
    required this.unitsCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Estate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
