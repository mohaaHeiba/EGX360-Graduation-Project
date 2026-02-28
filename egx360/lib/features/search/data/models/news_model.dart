import 'package:egx/features/search/data/models/stock_model.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  NewsModel({
    required super.id,
    required super.title,
    super.source,
    required super.publishedAt,
    super.content,
    super.url,
    super.stock,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'].toString(),
      title: json['title'],
      source: json['source'],
      publishedAt: json['published_at'],
      content: json['content'],
      url: json['url'],
      stock: json['stocks'] != null
          ? StockModel.fromJson(json['stocks'])
          : null,
    );
  }
}
