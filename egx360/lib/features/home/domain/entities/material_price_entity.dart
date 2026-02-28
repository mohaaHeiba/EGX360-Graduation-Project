class MaterialPriceEntity {
  final DateTime timestamp;
  final double price24k;
  final double price22k;
  final double price21k;
  final double price18k;
  final double silver999;
  final double silver800;

  MaterialPriceEntity({
    required this.timestamp,
    required this.price24k,
    required this.price22k,
    required this.price21k,
    required this.price18k,
    required this.silver999,
    required this.silver800,
  });
}
