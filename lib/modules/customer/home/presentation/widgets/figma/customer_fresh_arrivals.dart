import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/theme/design_tokens.dart';
import '../../../../../../core/util/unsplash_raster_url.dart';
import '../../../../../../core/utils/money.dart';
import '../../../../cart/presentation/controllers/cart_controller.dart';
import '../../../../cart/presentation/widgets/cart_qty_stepper.dart';
import '../../../../product/domain/entities/product.dart';
import '../../../../product/domain/entities/product_variant.dart';
import '../../../../product/domain/extensions/product_pack_extensions.dart';
import '../../../../product/presentation/controllers/product_list_controller.dart';

/// Blinkit-style 2-column product grid — white cards, circular image tray, ETA pill,
/// optional discount / Ad badge, outline **ADD** (Figma Customer Home export).
class CustomerFreshArrivalsBlock extends StatelessWidget {
  const CustomerFreshArrivalsBlock({super.key});

  static const double _gridGap = 12;
  static const double _cardMainExtent = 278;

  @override
  Widget build(BuildContext context) {
    final list = Get.find<ProductListController>();
    final cart = Get.find<CartController>();

    return Obx(() {
      if (list.loading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.spaceLg),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (list.error.value != null) {
        return Text(list.error.value!, textAlign: TextAlign.center);
      }
      final items = list.products.take(4).toList();
      if (items.isEmpty) {
        return Text(
          AppStrings.catalog,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: _gridGap,
              mainAxisSpacing: _gridGap,
              mainAxisExtent: _cardMainExtent,
            ),
            itemBuilder: (context, index) {
              return CustomerArrivalProductCard(
                product: items[index],
                cart: cart,
                gridIndex: index,
                maxCrossAxisExtent: maxW,
              );
            },
          );
        },
      );
    });
  }
}

class CustomerArrivalProductCard extends StatelessWidget {
  const CustomerArrivalProductCard({
    super.key,
    required this.product,
    required this.cart,
    required this.gridIndex,
    required this.maxCrossAxisExtent,
  });

  final Product product;
  final CartController cart;
  final int gridIndex;
  final double maxCrossAxisExtent;

  static const _surface = Color(0xFFEFF4FF);
  static const _titleInk = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _strike = Color(0xFF94A3B8);
  static const _badgeBlue = Color(0xFF2563EB);
  static const _adSurface = Color(0xFFF1F5F9);
  static const _adInk = Color(0xFF475569);
  static const _etaInk = Color(0xFF1E293B);

  int _derivedListMinor(ProductVariant v) {
    return v.priceMinor + (v.priceMinor * 20 ~/ 100);
  }

  int _percentOff(int list, int sale) {
    if (list <= sale || list <= 0) return 0;
    return (((list - sale) * 100) ~/ list).clamp(0, 99);
  }

  String _etaLabel() {
    const mins = [8, 12, 10, 15];
    return '${mins[gridIndex % mins.length]} MINS';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = product.preferredListVariant;
    if (v == null) return const SizedBox.shrink();

    final listMinor = _derivedListMinor(v);
    final pct = _percentOff(listMinor, v.priceMinor);
    final showStrike = pct >= 5;

    final cellW =
        (maxCrossAxisExtent - CustomerFreshArrivalsBlock._gridGap) / 2;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 17.5,
                            horizontal: 0,
                          ),
                          child: Center(
                            child: product.imageUrl != null
                                ? Image.network(
                                    unsplashAsJpeg(product.imageUrl!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        Icon(Icons.eco_rounded,
                                            color: scheme.primary, size: 48),
                                  )
                                : Icon(Icons.eco_rounded,
                                    color: scheme.primary, size: 48),
                          ),
                        ),
                      ),
                    ),
                    _buildTopBadge(pct),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 10,
                                color: _adInk,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _etaLabel(),
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  height: 14 / 9,
                                  fontWeight: FontWeight.w700,
                                  color: _etaInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 15 / 12,
                    fontWeight: FontWeight.w700,
                    color: _titleInk,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                v.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  height: 15 / 10,
                  fontWeight: FontWeight.w400,
                  color: _muted,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: showStrike ? 38 : 32,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showStrike)
                            Text(
                              formatInrMinor(listMinor),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                height: 15 / 10,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough,
                                color: _strike,
                              ),
                            ),
                          Text(
                            formatInrMinor(v.priceMinor),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w700,
                              color: _titleInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: (cellW - 24) * 0.42,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CartQtyStepper(
                          product: product,
                          variant: v,
                          cart: cart,
                          dense: true,
                          outlinedZeroAdd: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadge(int pct) {
    if (pct >= 12) {
      return Positioned(
        left: 0,
        top: 8,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: _badgeBlue,
            child: Text(
              '$pct% OFF',
              style: GoogleFonts.inter(
                fontSize: 9,
                height: 14 / 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    if (gridIndex % 4 == 1) {
      return Positioned(
        left: 0,
        top: 8,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: _adSurface,
            child: Text(
              'Ad',
              style: GoogleFonts.inter(
                fontSize: 9,
                height: 14 / 9,
                fontWeight: FontWeight.w700,
                color: _adInk,
              ),
            ),
          ),
        ),
      );
    }
    if (pct >= 5 && pct < 12) {
      return Positioned(
        left: 0,
        top: 8,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: _badgeBlue,
            child: Text(
              '$pct% OFF',
              style: GoogleFonts.inter(
                fontSize: 9,
                height: 14 / 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
