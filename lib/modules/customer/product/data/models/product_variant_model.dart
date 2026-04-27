import '../../../../../core/util/pack_weight.dart';
import '../../domain/entities/product_variant.dart';

class ProductVariantModel extends ProductVariant {
  const ProductVariantModel({
    required super.id,
    required super.label,
    required super.totalGrams,
    required super.priceMinor,
    required super.stock,
    required super.lowStockThreshold,
  });

  factory ProductVariantModel.fromEntity(ProductVariant v) {
    return ProductVariantModel(
      id: v.id,
      label: v.label,
      totalGrams: v.totalGrams,
      priceMinor: v.priceMinor,
      stock: v.stock,
      lowStockThreshold: v.lowStockThreshold,
    );
  }

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final label = (json['label'] ?? json['unit'] ?? '').toString();
    final gramsRaw = json['totalGrams'] ?? json['total_grams'];
    final grams = gramsRaw is num
        ? gramsRaw.toInt()
        : parsePackGrams(label) ?? 0;
    return ProductVariantModel(
      id: (json['id'] ?? json['variant_id'] ?? '').toString(),
      label: label,
      totalGrams: grams > 0 ? grams : (parsePackGrams(label) ?? 1),
      priceMinor: _readPriceMinor(json),
      stock: (json['stock'] as num?)?.toInt() ??
          (json['inventory'] as num?)?.toInt() ??
          0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ??
          (json['low_stock_threshold'] as num?)?.toInt() ??
          5,
    );
  }

  static int _readPriceMinor(Map<String, dynamic> json) {
    final priceMinor = json['priceMinor'] ?? json['price_minor'];
    if (priceMinor is num) return priceMinor.toInt();
    if (priceMinor is String) return int.tryParse(priceMinor) ?? 0;

    final price = json['price'];
    if (price is num) return (price * 100).round();
    if (price is String) {
      final parsed = double.tryParse(price);
      if (parsed != null) return (parsed * 100).round();
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'totalGrams': totalGrams,
        'priceMinor': priceMinor,
        'stock': stock,
        'lowStockThreshold': lowStockThreshold,
      };
}
