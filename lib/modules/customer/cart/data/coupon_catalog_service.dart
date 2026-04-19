import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/coupon_catalog_entry.dart';
import '../domain/coupon_offer.dart';
import '../../../../shared/firebase/repositories/shared_coupon_firestore_repository.dart';

/// Reads pack-aware coupons from Firestore `coupons/{code}`.
class CouponCatalogService {
  CouponCatalogService({
    SharedCouponFirestoreRepository? coupons,
    FirebaseFirestore? db,
  }) : _coupons = coupons ?? SharedCouponFirestoreRepository(db);

  final SharedCouponFirestoreRepository _coupons;

  DateTime? _expiresFrom(Map<String, dynamic> m) {
    final raw = m['expiresAt'] ?? m['expires_at'];
    if (raw is Timestamp) return raw.toDate();
    return null;
  }

  /// Browse flow — documents under `coupons/` (admin / Console).
  Future<List<CouponCatalogEntry>> fetchAllCatalogEntries() async {
    final merged = <String, CouponCatalogEntry>{};
    try {
      final snap = await _coupons.fetchCoupons(limit: 80);
      for (final doc in snap.docs) {
        final m = Map<String, dynamic>.from(doc.data());
        final offer = CouponOffer.fromFirestoreMap(m);
        if (offer == null) continue;
        merged[offer.code] = CouponCatalogEntry.fromParsed(
          offer: offer,
          badge: m['badge'] as String? ?? m['category'] as String?,
          description: m['description'] as String?,
          expiresAt: _expiresFrom(m),
        );
      }
    } on Object {
      // Permission / network — return whatever we collected (often empty).
    }
    final list = merged.values.toList()
      ..sort((a, b) => b.offer.percentOff.compareTo(a.offer.percentOff));
    return list;
  }

  Future<CouponOffer?> fetchOffer(String code) async {
    final id = code.trim().toUpperCase();
    if (id.isEmpty) return null;
    try {
      final snap = await _coupons.fetchCoupon(id);
      if (!snap.exists) return null;
      final m = snap.data();
      if (m == null) return null;
      return CouponOffer.fromFirestoreMap(m);
    } on Object {
      return null;
    }
  }
}
