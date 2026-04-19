import 'coupon_offer.dart';
import 'entities/cart_line.dart';

/// Percent discount on **eligible line subtotal** only (Blinkit-style pack promos).
class PackCouponEvaluator {
  PackCouponEvaluator._();

  /// Line earns discount only if every configured rule passes (tier list + min grams).
  static bool _lineQualifies(CartLine line, CouponOffer offer) {
    final g = gramsForCartLine(line);
    final tiers = offer.eligiblePackGrams;
    if (tiers != null && tiers.isNotEmpty && !tiers.contains(g)) {
      return false;
    }
    final min = offer.minPackGramsAnyLine;
    if (min != null && g < min) return false;
    return true;
  }

  static int _eligibleSubtotalMinor(List<CartLine> lines, CouponOffer offer) {
    int sum = 0;
    for (final line in lines) {
      if (_lineQualifies(line, offer)) {
        sum += line.lineTotalMinor;
      }
    }
    return sum;
  }

  /// `0` when inactive, cart empty, rules not met, or nothing eligible.
  static int discountMinor(List<CartLine> lines, CouponOffer offer) {
    if (!offer.active || offer.percentOff <= 0 || lines.isEmpty) return 0;
    final eligible = _eligibleSubtotalMinor(lines, offer);
    if (eligible <= 0) return 0;
    return (eligible * offer.percentOff) ~/ 100;
  }
}
