import 'package:egx/features/search/domain/entities/stock_entity.dart';

class NewsEntity {
  final String id;
  final String title;
  final String? source;
  final String publishedAt;
  final String? content;
  final String? url;
  final StockEntity? stock;

  NewsEntity({
    required this.id,
    required this.title,
    this.source,
    required this.publishedAt,
    this.content,
    this.url,
    this.stock,
  });
}
