import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../shared/firebase/repositories/shared_catalog_firestore_repository.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';
import 'product_remote_datasource.dart';

/// Catalog from Firestore `products` collection (shape aligned with [ProductModel.toJson] / test seed).
class ProductFirestoreDataSource implements ProductRemoteDataSource {
  ProductFirestoreDataSource({
    SharedCatalogFirestoreRepository? catalog,
    FirebaseFirestore? firestore,
  }) : _catalog = catalog ?? SharedCatalogFirestoreRepository(firestore);

  final SharedCatalogFirestoreRepository _catalog;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final snap = await _catalog.fetchProducts();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  ProductModel _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    final rawVariants = m['variants'] as List<dynamic>? ?? [];
    final variants = rawVariants.map((e) {
      final v = Map<String, dynamic>.from(e as Map);
      return ProductVariantModel.fromJson(_normalizeVariantJson(v));
    }).toList();
    return ProductModel(
      id: doc.id,
      name: m['name'] as String? ?? '',
      description: m['description'] as String?,
      imageUrl: m['image_url'] as String? ?? m['imageUrl'] as String?,
      variants: variants,
    );
  }

  /// Coerce numeric ids from Firestore into strings for [ProductVariantModel].
  Map<String, dynamic> _normalizeVariantJson(Map<String, dynamic> v) {
    final id = v['id'];
    final label = v['label'] as String? ?? v['name'] as String? ?? '';
    final grams = v['totalGrams'] ?? v['total_grams'];
    return {
      ...v,
      'id': id is String ? id : id?.toString() ?? '',
      'label': label,
      if (grams != null) 'totalGrams': grams,
      'priceMinor': (v['priceMinor'] as num?)?.toInt() ?? 0,
      'stock': (v['stock'] as num?)?.toInt() ?? 0,
      'lowStockThreshold': (v['lowStockThreshold'] as num?)?.toInt() ?? 5,
    };
  }
}
