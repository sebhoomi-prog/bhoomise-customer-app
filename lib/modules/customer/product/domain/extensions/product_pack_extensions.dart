import '../entities/product.dart';
import '../entities/product_variant.dart';

extension ProductPackListing on Product {
  /// Blinkit-style: smallest pack first (200 g → 500 g → 1 kg …).
  List<ProductVariant> get variantsSortedByPack {
    final list = [...variants]
      ..sort((a, b) => a.totalGrams.compareTo(b.totalGrams));
    return list;
  }

  /// Default row on home: cheapest in-stock smallest pack users can add quickly.
  ProductVariant? get preferredListVariant {
    final sorted = variantsSortedByPack;
    if (sorted.isEmpty) return null;
    for (final v in sorted) {
      if (!v.isOutOfStock) return v;
    }
    return sorted.first;
  }
}
