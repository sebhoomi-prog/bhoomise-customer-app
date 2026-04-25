import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import 'models/coupon_api_models.dart';

import '../domain/coupon_catalog_entry.dart';
import '../domain/coupon_offer.dart';

/// Reads pack-aware coupons from Laravel REST API.
class CouponCatalogService {
  CouponCatalogService(this._apiClient);

  final ApiClient _apiClient;

  /// Browse flow — `GET /coupons`.
  Future<List<CouponCatalogEntry>> fetchAllCatalogEntries() async {
    final merged = <String, CouponCatalogEntry>{};
    try {
      final response = await _apiClient.get(ApiEndpoints.coupons);
      final items = CouponListResponseModel.fromApi(response.data).items;
      for (final c in items) {
        final offer = CouponOffer.fromFirestoreMap(c.toCouponOfferMap());
        if (offer == null) continue;
        merged[offer.code] = CouponCatalogEntry.fromParsed(
          offer: offer,
          badge: c.badge,
          description: c.description,
          expiresAt: c.expiresAt,
        );
      }
    } on Object {
      // Silently ignore fetch errors; coupons are optional.
    }
    final list = merged.values.toList()
      ..sort((a, b) => b.offer.percentOff.compareTo(a.offer.percentOff));
    return list;
  }

  Future<CouponOffer?> fetchOffer(String code) async {
    final id = code.trim().toUpperCase();
    if (id.isEmpty) return null;
    try {
      final response = await _apiClient.get('${ApiEndpoints.coupons}/$id');
      final c = CouponSingleResponseModel.fromApi(response.data).item;
      return CouponOffer.fromFirestoreMap(c.toCouponOfferMap());
    } on Object {
      return null;
    }
  }
}
