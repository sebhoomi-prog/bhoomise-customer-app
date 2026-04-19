import '../../../../../core/network/mock_asset_client.dart';
import '../../../../../core/util/pack_weight.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import 'product_remote_datasource.dart';

/// Catalog from `assets/mock_api/product/products_index.json` (`data.items`).
class ProductAssetDataSource implements ProductRemoteDataSource {
  ProductAssetDataSource(this._assets);

  final MockAssetClient _assets;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final data = await _assets.getData('product/products_index.json');
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => _productFromApi(e as Map<String, dynamic>))
        .toList();
  }

  static ProductModel _productFromApi(Map<String, dynamic> m) {
    final variants = (m['variants'] as List<dynamic>? ?? [])
        .map((e) => _variantFromApi(e as Map<String, dynamic>))
        .toList();
    return ProductModel(
      id: m['id'].toString(),
      name: m['name'] as String,
      description: m['description'] as String?,
      imageUrl: m['image_url'] as String? ?? m['hero_image_url'] as String?,
      variants: variants,
    );
  }

  static ProductVariantModel _variantFromApi(Map<String, dynamic> v) {
    final price = v['price'];
    final name = v['name'] as String? ?? '';
    final gramsRaw = v['total_grams'] ?? v['totalGrams'];
    final grams = gramsRaw is num
        ? gramsRaw.toInt()
        : parsePackGrams(name) ?? 1;
    return ProductVariantModel(
      id: v['id'].toString(),
      label: name,
      totalGrams: grams > 0 ? grams : 1,
      priceMinor: _inrStringOrNumToMinor(price),
      stock: (v['stock'] as num?)?.toInt() ?? 100,
      lowStockThreshold: (v['low_stock_threshold'] as num?)?.toInt() ?? 5,
    );
  }

  static int _inrStringOrNumToMinor(dynamic price) {
    if (price is num) {
      return (price * 100).round();
    }
    if (price is String) {
      return (double.parse(price) * 100).round();
    }
    return 0;
  }
}
