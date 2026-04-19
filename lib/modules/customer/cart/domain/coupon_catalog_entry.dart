import 'coupon_offer.dart';

/// Enriched coupon for browse / apply UI (Firestore fields + sensible defaults).
class CouponCatalogEntry {
  const CouponCatalogEntry({
    required this.offer,
    required this.badgeLabel,
    required this.description,
    this.expiresAt,
  });

  final CouponOffer offer;
  final String badgeLabel;
  final String description;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  /// Eligible for basket discount rules (Firestore `active` + not past expiry).
  bool get isUsable =>
      offer.active && !isExpired;

  bool get isExpiringSoon {
    if (expiresAt == null || isExpired) return false;
    final days = expiresAt!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 7;
  }

  static String defaultBadge(CouponOffer o) {
    if (o.minPackGramsAnyLine != null) return 'BULK SAVINGS';
    if (o.eligiblePackGrams != null && o.eligiblePackGrams!.isNotEmpty) {
      return 'PACK SPECIAL';
    }
    return 'SEASONAL SPECIAL';
  }

  static String defaultDescription(CouponOffer o) {
    if (!o.active) return 'This promotion is not active.';
    if (o.minPackGramsAnyLine != null) {
      final kg = o.minPackGramsAnyLine! / 1000;
      return 'Requires at least ${kg >= 1 ? '${kg.toStringAsFixed(kg == kg.roundToDouble() ? 0 : 1)} kg' : '${o.minPackGramsAnyLine} g'} pack in your bag.';
    }
    if (o.eligiblePackGrams != null && o.eligiblePackGrams!.isNotEmpty) {
      return 'Applies only to selected pack sizes in your basket.';
    }
    return '${o.percentOff}% off eligible items in your basket.';
  }

  factory CouponCatalogEntry.fromParsed({
    required CouponOffer offer,
    String? badge,
    String? description,
    DateTime? expiresAt,
  }) {
    final b = badge?.trim();
    final d = description?.trim();
    return CouponCatalogEntry(
      offer: offer,
      badgeLabel: (b != null && b.isNotEmpty) ? b : defaultBadge(offer),
      description: (d != null && d.isNotEmpty) ? d : defaultDescription(offer),
      expiresAt: expiresAt,
    );
  }
}
