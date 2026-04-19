class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.totalGrams,
    required this.priceMinor,
    required this.stock,
    required this.lowStockThreshold,
  });

  final String id;
  final String label;
  /// Normalized pack weight for pricing / coupons (e.g. 200, 500, 1000, 10000).
  final int totalGrams;
  final int priceMinor;
  final int stock;
  final int lowStockThreshold;

  bool get isLowStock => stock > 0 && stock <= lowStockThreshold;
  bool get isOutOfStock => stock <= 0;
}
