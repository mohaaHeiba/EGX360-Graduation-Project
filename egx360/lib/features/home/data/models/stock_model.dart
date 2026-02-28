import 'package:egx/features/search/domain/entities/stock_entity.dart';

class StockModel extends StockEntity {
  StockModel({
    required super.id,
    required super.symbol,
    super.companyNameAr,
    super.companyNameEn,
    super.logoUrl,
    super.sector,
    super.assetType,
    super.description,
    super.totalShares,
    super.isinCode,
    super.website,
    super.listingDate,
    super.candleTableName,
    super.prevClose,
    super.sparklineData,
    this.currentPrice,
    this.changePercent,
  });

  final double? currentPrice;
  final double? changePercent;

  factory StockModel.fromJson(Map<String, dynamic> json) {
    final sparklineData = json['sparkline_data'] != null
        ? (json['sparkline_data'] as List)
              .map((e) => (e as num).toDouble())
              .toList()
        : null;

    return StockModel(
      id: json['id'].toString(),
      symbol: json['symbol'] ?? '',
      companyNameAr: json['company_name_ar'],
      companyNameEn: json['company_name_en'],
      logoUrl: json['logo_url'],
      sector: json['sector'],
      assetType: 'STOCK', // Default to STOCK as column is missing
      description: json['description'],
      totalShares: json['total_shares'],
      isinCode: json['isin_code'],
      website: json['website'],
      candleTableName: json['candle_table_name'],
      prevClose: json['prev_close'] != null
          ? (json['prev_close'] as num).toDouble()
          : 0.0,
      currentPrice: json['current_price'] != null
          ? (json['current_price'] as num).toDouble()
          : 0.0,
      changePercent: json['change_percent'] != null
          ? (json['change_percent'] as num).toDouble()
          : 0.0,
      listingDate: json['listing_date'] != null
          ? DateTime.tryParse(json['listing_date'])
          : null,
      sparklineData: sparklineData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'company_name_ar': companyNameAr,
      'company_name_en': companyNameEn,
      'logo_url': logoUrl,
      'sector': sector,
      // 'asset_type': assetType, // Column missing in DB
      'description': description,
      'total_shares': totalShares,
      'isin_code': isinCode,
      'website': website,
      'candle_table_name': candleTableName,
      'prev_close': prevClose,
      'current_price': currentPrice,
      'change_percent': changePercent,
      'listing_date': listingDate?.toIso8601String(),
    };
  }
}
