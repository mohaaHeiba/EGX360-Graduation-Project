enum AssetType { stock, crypto, material, marketIndex }

extension AssetTypeExtension on AssetType {
  String get displayName {
    switch (this) {
      case AssetType.stock:
        return 'Stock';
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.material:
        return 'Material';
      case AssetType.marketIndex:
        return 'Index';
    }
  }

  bool get isCrypto => this == AssetType.crypto;
  bool get isStock => this == AssetType.stock;
  bool get isMaterial => this == AssetType.material;
  bool get isMarketIndex => this == AssetType.marketIndex;
}
