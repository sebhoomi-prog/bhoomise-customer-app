import '../../../../../core/util/product_image_url.dart';
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
      if (data is Map) {
        // Backend currently returns `data.products`; keep `data.items` fallback
        // for compatibility with older payloads.
        final nested = data['products'] ?? data['items'];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      final topLevel = map['products'] ?? map['items'];
      if (topLevel is List) {
        return topLevel
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
    var variants = variantsRaw is List
        ? variantsRaw
            .whereType<Map>()
            .map((v) => _toVariant(Map<String, dynamic>.from(v)))
            .toList()
        : const <ProductVariantModel>[];

    if (variants.isEmpty) {
      final fallbackVariant = _toVariant(m);
      if (fallbackVariant.id.isNotEmpty) {
        variants = <ProductVariantModel>[fallbackVariant];
      }
    }

    final productName = (m['name'] ?? m['product_name'] ?? m['display_name'] ?? '')
        .toString();

    return ProductModel(
      id: (m['id'] ?? m['product_id'] ?? '').toString(),
      name: productName,
      description: m['description']?.toString(),
      imageUrl: sanitizeProductImageUrl(
        m['image_url']?.toString() ?? m['hero_image_url']?.toString(),
      ),
      variants: variants,
    );
  }

  static ProductVariantModel _toVariant(Map<String, dynamic> v) {
    final priceMinor = _priceMinorFrom(v);
    final normalized = <String, dynamic>{
      'id': (v['id'] ?? v['variant_id'] ?? v['product_id'] ?? '').toString(),
      'label': (v['label'] ?? v['unit'] ?? v['name'] ?? '').toString(),
      'totalGrams': v['total_grams'] ?? v['totalGrams'],
      'priceMinor': priceMinor,
      'stock': (v['stock'] as num?)?.toInt() ?? (v['inventory'] as num?)?.toInt() ?? 0,
      'lowStockThreshold': (v['low_stock_threshold'] as num?)?.toInt() ??
          (v['lowStockThreshold'] as num?)?.toInt() ??
          5,
    };
    return ProductVariantModel.fromJson(normalized);
  }

  static int _priceMinorFrom(Map<String, dynamic> v) {
    if (v['priceMinor'] != null) return _asInt(v['priceMinor']);
    if (v['price_minor'] != null) return _asInt(v['price_minor']);
    return _priceToMinor(v['price']);
  }

  static int _asInt(dynamic raw) {
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
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
