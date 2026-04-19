import 'package:get/get.dart';

import '../data/coupon_catalog_service.dart';
import '../domain/coupon_offer.dart';
import '../domain/pack_coupon_evaluator.dart';
import 'controllers/cart_controller.dart';

/// Shared validation for typed codes (cart page + browse coupons screen).
class ApplyCouponOutcome {
  const ApplyCouponOutcome._({
    required this.isSuccess,
    this.offer,
    this.errorMessage,
  });

  final bool isSuccess;
  final CouponOffer? offer;
  final String? errorMessage;

  factory ApplyCouponOutcome.success(CouponOffer offer) =>
      ApplyCouponOutcome._(isSuccess: true, offer: offer);

  factory ApplyCouponOutcome.failure(String message) =>
      ApplyCouponOutcome._(isSuccess: false, errorMessage: message);
}

Future<ApplyCouponOutcome> applyCouponCodeToCart({
  required CartController cart,
  required String rawCode,
  CouponCatalogService? catalog,
}) async {
  final svc = catalog ?? Get.find<CouponCatalogService>();
  final code = rawCode.trim().toUpperCase();
  if (code.isEmpty) {
    return ApplyCouponOutcome.failure('');
  }
  if (cart.lines.isEmpty) {
    return ApplyCouponOutcome.failure('needs_items');
  }

  final offer = await svc.fetchOffer(code);

  if (offer == null || !offer.active) {
    return ApplyCouponOutcome.failure('invalid');
  }

  final discountMinor = PackCouponEvaluator.discountMinor(cart.lines, offer);
  if (discountMinor <= 0 && offer.hasPackTargeting) {
    final key = offer.minPackGramsAnyLine != null ? 'min_pack' : 'ineligible';
    return ApplyCouponOutcome.failure(key);
  }

  return ApplyCouponOutcome.success(offer);
}
