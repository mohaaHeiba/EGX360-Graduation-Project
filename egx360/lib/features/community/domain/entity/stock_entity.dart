class StockEntity {
  final String symbol;
  final String companyNameEn;
  final String companyNameAr;
  final String sector;
  final String? logoUrl;

  const StockEntity({
    required this.symbol,
    required this.companyNameEn,
    required this.companyNameAr,
    required this.sector,
    this.logoUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockEntity && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;
}
