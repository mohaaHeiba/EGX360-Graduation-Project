import 'package:egx/features/community/domain/entity/stock_entity.dart';

class StockModel extends StockEntity {
  const StockModel({
    required super.symbol,
    required super.companyNameEn,
    required super.companyNameAr,
    required super.sector,
    super.logoUrl,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      companyNameEn: json['company_name_en'] ?? '',
      companyNameAr: json['company_name_ar'] ?? '',
      sector: json['sector'] ?? '',
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'company_name_en': companyNameEn,
      'company_name_ar': companyNameAr,
      'sector': sector,
      'logo_url': logoUrl,
    };
  }
}
