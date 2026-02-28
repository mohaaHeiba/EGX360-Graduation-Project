/// Domain entity representing a saved viewport anchor point
/// Used to maintain chart position when historical data is loaded
class ViewportAnchor {
  final DateTime visibleMin;
  final DateTime visibleMax;
  final bool isRestoring;

  const ViewportAnchor({
    required this.visibleMin,
    required this.visibleMax,
    this.isRestoring = false,
  });

  ViewportAnchor copyWith({
    DateTime? visibleMin,
    DateTime? visibleMax,
    bool? isRestoring,
  }) {
    return ViewportAnchor(
      visibleMin: visibleMin ?? this.visibleMin,
      visibleMax: visibleMax ?? this.visibleMax,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewportAnchor &&
          runtimeType == other.runtimeType &&
          visibleMin == other.visibleMin &&
          visibleMax == other.visibleMax &&
          isRestoring == other.isRestoring;

  @override
  int get hashCode => Object.hash(visibleMin, visibleMax, isRestoring);

  @override
  String toString() =>
      'ViewportAnchor(visibleMin: $visibleMin, visibleMax: $visibleMax, isRestoring: $isRestoring)';
}
