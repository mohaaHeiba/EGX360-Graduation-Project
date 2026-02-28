import 'package:egx/features/markets/domain/entities/viewport_anchor.dart';

/// Data model for ViewportAnchor with JSON serialization support
class ViewportAnchorModel extends ViewportAnchor {
  const ViewportAnchorModel({
    required super.visibleMin,
    required super.visibleMax,
    super.isRestoring,
  });

  /// Create model from domain entity
  factory ViewportAnchorModel.fromEntity(ViewportAnchor entity) {
    return ViewportAnchorModel(
      visibleMin: entity.visibleMin,
      visibleMax: entity.visibleMax,
      isRestoring: entity.isRestoring,
    );
  }

  /// Create model from JSON
  factory ViewportAnchorModel.fromJson(Map<String, dynamic> json) {
    return ViewportAnchorModel(
      visibleMin: DateTime.parse(json['visibleMin'] as String),
      visibleMax: DateTime.parse(json['visibleMax'] as String),
      isRestoring: json['isRestoring'] as bool? ?? false,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'visibleMin': visibleMin.toIso8601String(),
      'visibleMax': visibleMax.toIso8601String(),
      'isRestoring': isRestoring,
    };
  }

  /// Convert model to domain entity
  ViewportAnchor toEntity() => this;
}
