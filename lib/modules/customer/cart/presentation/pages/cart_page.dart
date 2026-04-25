import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../bloc/cart/index.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/utils/money.dart';
import '../../domain/coupon_offer.dart';
import '../../domain/pack_coupon_evaluator.dart';
import '../../domain/entities/cart_line.dart';
import '../apply_cart_coupon.dart';

/// Customer cart — Figma: Your Basket, line cards, voucher, breakdown, checkout CTA.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponCtrl = TextEditingController();
  /// Applied promotion (Firestore or local demo); discount depends on pack sizes in bag.
  CouponOffer? _appliedCoupon;

  static const _body = Color(0xFF3E4A3D);
  static const _deliveryMinor = 499;
  static const _handlingMinor = 150;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  int _taxMinor(int taxableMinor) => (taxableMinor * 8 + 50) ~/ 100;

  Future<void> _tryApplyCoupon(CartBlocState cart) async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterVoucherHint)),
      );
      return;
    }
    final out = await applyCouponCodeToCart(
      cart: cart,
      rawCode: code,
    );
    if (!out.isSuccess) {
      setState(() => _appliedCoupon = null);
      if (!mounted) return;
      final msg = switch (out.errorMessage) {
        'needs_items' => AppStrings.voucherNeedsItems,
        'invalid' => AppStrings.invalidVoucher,
        'min_pack' => AppStrings.voucherMinPackNotMet,
        'ineligible' => AppStrings.voucherPackIneligible,
        _ => AppStrings.invalidVoucher,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    setState(() => _appliedCoupon = out.offer);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.voucherApplied)),
    );
  }

  String _tagForLine(CartLine line) {
    if (line.lineTag != null && line.lineTag!.trim().isNotEmpty) {
      return line.lineTag!.trim().toUpperCase();
    }
    const tags = ['SPORE-GROWN', 'WILD FORAGED', 'ARTISAN CRAFT'];
    return tags[line.productId.hashCode.abs() % tags.length];
  }

  @override
  Widget build(BuildContext context) {
    final cartBloc = context.read<CartBloc>();

    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: BlocBuilder<CartBloc, CartBlocState>(builder: (context, cart) {
        final lines = cart.lines.toList();
        final subtotal = cart.totalMinor;
        final discountMinor = _appliedCoupon == null
            ? 0
            : PackCouponEvaluator.discountMinor(
                lines,
                _appliedCoupon!,
              );
        final afterDiscount = (subtotal - discountMinor).clamp(0, 1 << 30);
        final tax = _taxMinor(afterDiscount);
        final grandTotal =
            afterDiscount + _deliveryMinor + _handlingMinor + tax;
        final headerTop = MediaQuery.paddingOf(context).top + 72;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              displacement: headerTop + 48,
              onRefresh: () async => cartBloc.add(const CartLoadRequested()),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.spaceLg,
                    headerTop + DesignTokens.spaceLg,
                    DesignTokens.spaceLg,
                    MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (lines.isEmpty)
                        _EmptyCartBody()
                      else ...[
                        Text(
                          AppStrings.yourBasket,
                          style: GoogleFonts.manrope(
                            fontSize: 36,
                            height: 40 / 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.9,
                            color: DesignTokens.figmaSectionInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.curatedItemsSelected(
                            cart.totalItemQuantity,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w500,
                            color: _body,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        ...lines.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _CartLineCard(
                              line: line,
                              tag: _tagForLine(line),
                              onMinus: () {
                                if (line.quantity <= 1) {
                                  cartBloc.add(CartRemoveRequested(line));
                                } else {
                                  cartBloc.add(CartDecrementRequested(line));
                                }
                              },
                              onPlus: () =>
                                  cartBloc.add(CartIncrementRequested(line)),
                              onDelete: () =>
                                  cartBloc.add(CartRemoveRequested(line)),
                            ),
                          ),
                        ),
                        _VoucherSection(
                          controller: _couponCtrl,
                          onApply: () {
                            unawaited(_tryApplyCoupon(cart));
                          },
                          onSeeAllCoupons: () async {
                            final dynamic r =
                                await Get.toNamed(AppRoutes.availableCoupons);
                            if (!context.mounted) return;
                            if (r is String && r.isNotEmpty) {
                              _couponCtrl.text = r;
                              await _tryApplyCoupon(cart);
                            }
                          },
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        _PriceBreakdown(
                          cart: cart,
                          subtotalMinor: subtotal,
                          discountMinor: discountMinor,
                          deliveryMinor: _deliveryMinor,
                          handlingMinor: _handlingMinor,
                          taxMinor: tax,
                          grandTotalMinor: grandTotal,
                        ),
                        const SizedBox(height: 8),
                        _ProceedCheckoutBar(
                          enabled: lines.isNotEmpty,
                          onPressed: lines.isEmpty
                              ? null
                              : () {
                                  Get.toNamed(
                                    AppRoutes.orderTrack,
                                    arguments: 'SH-9921',
                                  );
                                },
                        ),
                      ],
                    ]),
                  ),
                ),
                ],
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _CartFrostedHeader(),
            ),
          ],
        );
      }),
    );
  }
}

class _CartFrostedHeader extends StatelessWidget {
  const _CartFrostedHeader();

  /// Matches order track / catalog toolbars — one optional back control, centered title.
  static const double _kToolbarSideSlot = 56;

  @override
  Widget build(BuildContext context) {
    final canPop = routeCanPop(context);
    final scheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: DesignTokens.figmaHeaderFrostTint.withValues(alpha: 0.7),
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            MediaQuery.paddingOf(context).top + DesignTokens.spaceMd,
            DesignTokens.spaceLg,
            DesignTokens.spaceMd,
          ),
          child: Row(
            children: [
              SizedBox(
                width: canPop ? _kToolbarSideSlot : 0,
                child: canPop
                    ? Center(
                        child: adaptiveFrostedBackControl(
                          context,
                          iconColor: scheme.onSurface,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  AppStrings.navOrders,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: DesignTokens.figmaDeliverGreen,
                  ),
                ),
              ),
              SizedBox(width: canPop ? _kToolbarSideSlot : 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCartBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXl),
      child: Column(
        children: [
          Text(
            AppStrings.yourBasket,
            style: GoogleFonts.manrope(
              fontSize: 36,
              height: 40 / 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
              color: DesignTokens.figmaSectionInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.curatedItemsSelected(0),
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: _CartPageState._body,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXl),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceXl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          Text(
            AppStrings.emptyCart,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            'Add items from the catalogue to see them here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
    required this.tag,
    required this.onMinus,
    required this.onPlus,
    required this.onDelete,
  });

  final CartLine line;
  final String tag;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 96,
              height: 96,
              color: DesignTokens.figmaCategoryCard,
              child: line.imageUrl != null && line.imageUrl!.isNotEmpty
                  ? Image.network(
                      line.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Center(child: _imageFallback()),
                    )
                  : Center(child: _imageFallback()),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              height: 15 / 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: DesignTokens.figmaStoreMeta,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            line.productName,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              height: 28 / 18,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.figmaSectionInk,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              line.variantLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 18 / 13,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.figmaHeroCtaGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        formatInrMinor(line.unitPriceMinor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.figmaHeroCtaGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: DesignTokens.figmaCartQtyPill,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyIconBtn(icon: Icons.remove, onPressed: onMinus),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${line.quantity}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.figmaSectionInk,
                              ),
                            ),
                          ),
                          _QtyIconBtn(icon: Icons.add, onPressed: onPlus),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: DesignTokens.figmaLabelMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Icon(
      Icons.eco_rounded,
      size: 40,
      color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.35),
    );
  }
}

class _QtyIconBtn extends StatelessWidget {
  const _QtyIconBtn({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 16,
            color: DesignTokens.figmaSectionInk,
          ),
        ),
      ),
    );
  }
}

class _VoucherSection extends StatelessWidget {
  const _VoucherSection({
    required this.controller,
    required this.onApply,
    required this.onSeeAllCoupons,
  });

  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onSeeAllCoupons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.figmaCategoryCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.voucherCode,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.figmaSectionInk,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: DesignTokens.figmaHeroCtaGreen,
                ),
                onPressed: onSeeAllCoupons,
                child: Text(
                  AppStrings.seeAllCoupons,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 17 / 14,
                    color: DesignTokens.figmaSectionInk,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    hintText: AppStrings.voucherPlaceholder,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceLg,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Material(
                color: DesignTokens.figmaVoucherApplyBg,
                borderRadius: BorderRadius.circular(9999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: onApply,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    child: Text(
                      AppStrings.apply,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.figmaVoucherApplyFg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.cart,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.deliveryMinor,
    required this.handlingMinor,
    required this.taxMinor,
    required this.grandTotalMinor,
  });

  final CartBlocState cart;
  final int subtotalMinor;
  final int discountMinor;
  final int deliveryMinor;
  final int handlingMinor;
  final int taxMinor;
  final int grandTotalMinor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _MoneyRow(
            label: AppStrings.subtotalWithItemCount(cart.totalItemQuantity),
            valueMinor: subtotalMinor,
            labelWeight: FontWeight.w500,
          ),
          if (discountMinor > 0) ...[
            const SizedBox(height: 12),
            _MoneyRow(
              label: 'Voucher',
              valueMinor: -discountMinor,
              valueGreen: true,
              labelWeight: FontWeight.w500,
            ),
          ],
          const SizedBox(height: 12),
          _MoneyRow(
            label: AppStrings.sustainableDelivery,
            valueMinor: deliveryMinor,
            labelWeight: FontWeight.w500,
          ),
          const SizedBox(height: 12),
          _MoneyRow(
            label: AppStrings.ecoHandlingFee,
            valueMinor: handlingMinor,
            labelWeight: FontWeight.w500,
          ),
          const SizedBox(height: 12),
          _MoneyRow(
            label: AppStrings.estimatedTaxes,
            valueMinor: taxMinor,
            labelWeight: FontWeight.w500,
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0x33BDCABA),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.total,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.figmaSectionInk,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Flexible(
                child: Text(
                  formatInrMinor(grandTotalMinor),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.figmaHeroCtaGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.valueMinor,
    required this.labelWeight,
    this.valueGreen = false,
  });

  final String label;
  final int valueMinor;
  final FontWeight labelWeight;
  final bool valueGreen;

  @override
  Widget build(BuildContext context) {
    final valueText = valueMinor < 0
        ? '-${formatInrMinor(-valueMinor)}'
        : formatInrMinor(valueMinor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: labelWeight,
              color: const Color(0xFF3E4A3D),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceSm),
        Flexible(
          flex: 2,
          child: Text(
            valueText,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: valueGreen
                  ? DesignTokens.figmaHeroCtaGreen
                  : DesignTokens.figmaSectionInk,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProceedCheckoutBar extends StatelessWidget {
  const _ProceedCheckoutBar({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: onPressed,
            child: Ink(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                gradient: enabled
                    ? const LinearGradient(
                        colors: [
                          DesignTokens.figmaHeroCtaGreen,
                          DesignTokens.figmaHeroCtaGreenAlt,
                        ],
                      )
                    : null,
                color: enabled ? null : DesignTokens.figmaNavInactive,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.proceedToCheckout,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      height: 28 / 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.secureEncryptedTransaction,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            height: 15 / 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: const Color(0xFF596373),
          ),
        ),
      ],
    );
  }
}
