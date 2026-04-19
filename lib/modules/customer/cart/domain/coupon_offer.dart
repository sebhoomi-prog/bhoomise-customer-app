import '../../../../core/util/pack_weight.dart';
import 'entities/cart_line.dart';

/// Loaded from Firestore `coupons/{CODE}` — authored via admin / Console.
class CouponOffer {
  const CouponOffer({
    required this.code,
    required this.percentOff,
    required this.active,
    this.eligiblePackGrams,
    this.minPackGramsAnyLine,
  });

  final String code;
  final int percentOff;
  final bool active;

  /// When non-empty, **only** lines whose pack size (grams) is in this set earn discount.
  /// When null or empty, all pack sizes count (subject to [minPackGramsAnyLine]).
  final List<int>? eligiblePackGrams;

  /// Cart must include at least one line whose pack is ≥ this many grams.
  final int? minPackGramsAnyLine;

  bool get hasPackTargeting =>
      (eligiblePackGrams != null && eligiblePackGrams!.isNotEmpty) ||
      minPackGramsAnyLine != null;

  static CouponOffer? fromFirestoreMap(Map<String, dynamic> m) {
    final code = (m['code'] as String?)?.trim().toUpperCase();
    if (code == null || code.isEmpty) return null;
    final pct = (m['percentOff'] as num?)?.toInt();
    if (pct == null || pct <= 0) return null;
    final active = m['active'] as bool? ?? true;
    if (!active) {
      return CouponOffer(code: code, percentOff: pct, active: false);
    }

    List<int>? grams;
    final raw = m['eligiblePackGrams'] ?? m['eligible_pack_grams'];
    if (raw is List) {
      grams = raw
          .map((e) => (e as num).toInt())
          .where((g) => g > 0)
          .toSet()
          .toList()
        ..sort();
      if (grams.isEmpty) grams = null;
    }

    final minPack = (m['minPackGramsAnyLine'] ?? m['min_pack_grams_any_line']) as num?;
    final minG = minPack?.toInt();

    return CouponOffer(
      code: code,
      percentOff: pct,
      active: true,
      eligiblePackGrams: grams,
      minPackGramsAnyLine: minG != null && minG > 0 ? minG : null,
    );
  }
}

int gramsForCartLine(CartLine line) {
  final g = line.variantGrams;
  if (g != null && g > 0) return g;
  return parsePackGrams(line.variantLabel) ?? 0;
}
