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
    final label = json['label'] as String;
    final gramsRaw = json['totalGrams'] ?? json['total_grams'];
    final grams = gramsRaw is num
        ? gramsRaw.toInt()
        : parsePackGrams(label) ?? 0;
    return ProductVariantModel(
      id: json['id'] as String,
      label: label,
      totalGrams: grams > 0 ? grams : (parsePackGrams(label) ?? 1),
      priceMinor: (json['priceMinor'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      lowStockThreshold: (json['lowStockThreshold'] as num).toInt(),
    );
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
