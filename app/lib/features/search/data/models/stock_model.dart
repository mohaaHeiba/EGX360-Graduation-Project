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
    super.currentPrice,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
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
          : null,
      listingDate: json['listing_date'] != null
          ? DateTime.tryParse(json['listing_date'])
          : null,
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
      'listing_date': listingDate?.toIso8601String(),
    };
  }

  @override
  StockModel copyWith({
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
    return StockModel(
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
    );
  }

  StockEntity toEntity() => this;
}
