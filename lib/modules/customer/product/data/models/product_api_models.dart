import 'product_model.dart';
import 'product_variant_model.dart';

class ProductListResponseModel {
  const ProductListResponseModel({required this.items});

  final List<ProductModel> items;

  factory ProductListResponseModel.fromApi(dynamic body) {
    final rawItems = _extractItems(body);
    final items = rawItems.map(_toProduct).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return ProductListResponseModel(items: items);
  }

  static List<Map<String, dynamic>> _extractItems(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (map['items'] is List) {
        return (map['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  static ProductModel _toProduct(Map<String, dynamic> m) {
    final variantsRaw = m['variants'];
    final variants = variantsRaw is List
        ? variantsRaw
            .whereType<Map>()
            .map((v) => _toVariant(Map<String, dynamic>.from(v)))
            .toList()
        : const <ProductVariantModel>[];
    return ProductModel(
      id: (m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      description: m['description']?.toString(),
      imageUrl: m['image_url']?.toString() ?? m['hero_image_url']?.toString(),
      variants: variants,
    );
  }

  static ProductVariantModel _toVariant(Map<String, dynamic> v) {
    final normalized = <String, dynamic>{
      'id': (v['id'] ?? '').toString(),
      'label': (v['label'] ?? v['name'] ?? '').toString(),
      'totalGrams': v['total_grams'] ?? v['totalGrams'],
      'priceMinor': _priceToMinor(v['price'] ?? v['priceMinor']),
      'stock': (v['stock'] as num?)?.toInt() ?? 0,
      'lowStockThreshold': (v['low_stock_threshold'] as num?)?.toInt() ??
          (v['lowStockThreshold'] as num?)?.toInt() ??
          5,
    };
    return ProductVariantModel.fromJson(normalized);
  }

  static int _priceToMinor(dynamic raw) {
    if (raw is num) return (raw * 100).round();
    if (raw is String) {
      final p = double.tryParse(raw);
      if (p != null) return (p * 100).round();
    }
    return 0;
  }
}
