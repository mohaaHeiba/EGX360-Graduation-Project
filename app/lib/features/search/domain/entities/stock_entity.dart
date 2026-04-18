class StockEntity {
  final String id;
  final String symbol;
  final String? companyNameAr;
  final String? companyNameEn;
  final String? logoUrl;
  final String? sector;
  final String? assetType;
  final String? description;
  final int? totalShares;
  final String? isinCode;
  final String? website;
  final DateTime? listingDate;
  final String? candleTableName;
  final double? prevClose;
  final double? currentPrice;
  List<double>? sparklineData;

  StockEntity({
    required this.id,
    required this.symbol,
    this.companyNameAr,
    this.companyNameEn,
    this.logoUrl,
    this.sector,
    this.assetType,
    this.description,
    this.totalShares,
    this.isinCode,
    this.website,
    this.listingDate,
    this.candleTableName,
    this.prevClose,
    this.sparklineData,
    this.currentPrice,
  });
  StockEntity copyWith({
    String? id,
    String? symbol,
    String? companyNameAr,
    String? companyNameEn,
    String? logoUrl,
    String? sector,
    String? assetType,
    String? description,
    int? totalShares,
    String? isinCode,
    String? website,
    DateTime? listingDate,
    String? candleTableName,
    double? prevClose,
    double? currentPrice,
    List<double>? sparklineData,
  }) {
    return StockEntity(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyNameAr: companyNameAr ?? this.companyNameAr,
      companyNameEn: companyNameEn ?? this.companyNameEn,
      logoUrl: logoUrl ?? this.logoUrl,
      sector: sector ?? this.sector,
      assetType: assetType ?? this.assetType,
      description: description ?? this.description,
      totalShares: totalShares ?? this.totalShares,
      isinCode: isinCode ?? this.isinCode,
      website: website ?? this.website,
      listingDate: listingDate ?? this.listingDate,
      candleTableName: candleTableName ?? this.candleTableName,
      prevClose: prevClose ?? this.prevClose,
      currentPrice: currentPrice ?? this.currentPrice,
      sparklineData: sparklineData ?? this.sparklineData,
    );
  }
}
