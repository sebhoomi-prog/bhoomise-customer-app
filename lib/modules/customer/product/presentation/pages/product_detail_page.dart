import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../bloc/cart/index.dart';
import '../../../../../bloc/home/index.dart';
import '../../../../../bloc/product/index.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/utils/money.dart';
import '../../../cart/domain/entities/cart_line.dart';
import '../../../cart/presentation/cart_action_feedback.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/extensions/product_pack_extensions.dart';

/// Customer PDP — Figma: hero, overlapping white card, frosted chrome, sticky cart bar.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _variantIndex = 0;
  int _qty = 1;
  bool _favorite = false;

  /// Prevents stacked [addLine] + Hive writes from rapid double-taps on "Add to cart".
  bool _addToCartBusy = false;

  static const _metaGrey = Color(0xFF596373);
  static const _body = Color(0xFF3E4A3D);
  static const _priceGreen = Color(0xFF006B2C);
  static const _freshnessTrack = Color(0xFF62DF7D);
  static const _borderTop = Color(0x1ABDCABA);

  Product? _resolveProduct() {
    final arg = Get.arguments;
    if (arg is Product) return arg;
    if (arg is String) {
      final list = Get.find<ProductBloc>().state.products;
      for (final p in list) {
        if (p.id == arg) return p;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final product = _resolveProduct();
    final cartBloc = context.read<CartBloc>();
    final cartState = context.watch<CartBloc>().state;

    if (product == null || product.variants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: adaptiveAppBarLeading(context),
          automaticallyImplyLeading: adaptiveAppBarImplyLeading(context),
          title: const Text('Product'),
        ),
        body: const Center(child: Text('Product not found')),
      );
    }

    final variants = product.variantsSortedByPack;
    _variantIndex = _variantIndex.clamp(0, variants.length - 1);
    final v = variants[_variantIndex];
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 442,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: DesignTokens.figmaCategoryCard,
                        child:
                            product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) =>
                                    _heroFallback(context),
                              )
                            : _heroFallback(context),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [0, 0.45, 1],
                              colors: [
                                DesignTokens.figmaHeaderFrostTint.withValues(
                                  alpha: 0.6,
                                ),
                                DesignTokens.figmaHeaderFrostTint.withValues(
                                  alpha: 0,
                                ),
                                DesignTokens.figmaHeaderFrostTint.withValues(
                                  alpha: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceLg,
                    ),
                    child: _ProductContentCard(
                      product: product,
                      variant: v,
                      variants: variants,
                      variantIndex: _variantIndex,
                      onVariantSelected: (i) =>
                          setState(() => _variantIndex = i),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 120 + bottomInset)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: DesignTokens.figmaHeaderFrostTint.withValues(
                    alpha: 0.7,
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: DesignTokens.spaceLg,
                    right: DesignTokens.spaceLg,
                    bottom: DesignTokens.spaceMd,
                  ),
                  child: Row(
                    children: [
                      if (routeCanPop(context))
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => routeMaybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: DesignTokens.figmaPinIconGreen,
                          ),
                        ),
                      if (routeCanPop(context)) const SizedBox(width: 4),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => _favorite = !_favorite),
                        icon: Icon(
                          _favorite ? Icons.favorite : Icons.favorite_border,
                          color: DesignTokens.figmaPinIconGreen,
                        ),
                      ),
                      _PdpProfileChip(
                        onTap: () => Get.toNamed(AppRoutes.profileEdit),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    border: const Border(top: BorderSide(color: _borderTop)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.spaceLg,
                    DesignTokens.spaceLg,
                    DesignTokens.spaceLg,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final narrow = c.maxWidth < 360;
                      final addHandler = v.isOutOfStock
                          ? null
                          : () async {
                              if (_addToCartBusy) return;
                              setState(() => _addToCartBusy = true);
                              final added = _qty;
                              try {
                                cartBloc.add(
                                  CartAddRequested(
                                    CartLine(
                                      productId: product.id,
                                      variantId: v.id,
                                      productName: product.name,
                                      variantLabel: v.label,
                                      unitPriceMinor: v.priceMinor,
                                      quantity: added,
                                      imageUrl: product.imageUrl,
                                      variantGrams: v.totalGrams,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                CartActionFeedback.notifyLineChange(
                                  context,
                                  product: product,
                                  variant: v,
                                  cart: cartState,
                                  delta: added,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _addToCartBusy = false);
                                }
                              }
                            };

                      final qty = _QuantityPill(
                        qty: _qty,
                        onMinus: (_addToCartBusy || _qty <= 1)
                            ? null
                            : () => setState(() => _qty--),
                        onPlus: _addToCartBusy
                            ? null
                            : () => setState(() => _qty++),
                      );
                      final btn = _AddToCartGradientButton(
                        inStock: !v.isOutOfStock,
                        busy: _addToCartBusy,
                        label: v.isOutOfStock
                            ? 'Unavailable'
                            : AppStrings.addToCart,
                        onPressed: addHandler,
                      );

                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(alignment: Alignment.center, child: qty),
                            const SizedBox(height: DesignTokens.spaceMd),
                            btn,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          qty,
                          const SizedBox(width: DesignTokens.spaceLg),
                          Expanded(child: btn),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroFallback(BuildContext context) {
    return ColoredBox(
      color: DesignTokens.figmaCategoryCard,
      child: Icon(
        Icons.eco_rounded,
        size: 96,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

class _PdpProfileChip extends StatelessWidget {
  const _PdpProfileChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: DesignTokens.figmaHeroCtaGreenAlt,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Builder(
              builder: (context) {
                if (Get.isRegistered<HomeBloc>()) {
                  final name = Get.find<HomeBloc>().state.profile?.displayName;
                  final initial = (name != null && name.isNotEmpty)
                      ? name.trim().substring(0, 1).toUpperCase()
                      : '?';
                  return Text(
                    initial,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  );
                }
                return Text(
                  '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductContentCard extends StatelessWidget {
  const _ProductContentCard({
    required this.product,
    required this.variant,
    required this.variants,
    required this.variantIndex,
    required this.onVariantSelected,
  });

  final Product product;
  final ProductVariant variant;
  final List<ProductVariant> variants;
  final int variantIndex;
  final ValueChanged<int> onVariantSelected;

  static const _ink = DesignTokens.figmaSectionInk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaPriceBlock(product: product, variant: variant),
          const SizedBox(height: DesignTokens.spaceMd),
          _RatingFreshnessRow(),
          if (variants.length > 1) ...[
            const SizedBox(height: DesignTokens.spaceLg),
            Text(
              'Choose pack size',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scroll to compare MRP for 200 g, 500 g, 1 kg, or bulk — like quick-commerce apps.',
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 16 / 12,
                color: _ProductDetailPageState._metaGrey,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: variants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final opt = variants[i];
                  final sel = i == variantIndex;
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(
                      opt.isOutOfStock ? '${opt.label} · OOS' : opt.label,
                    ),
                    selected: sel,
                    onSelected: opt.isOutOfStock
                        ? null
                        : (_) => onVariantSelected(i),
                    selectedColor: DesignTokens.figmaCategoryCard,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: opt.isOutOfStock
                          ? _ProductDetailPageState._metaGrey
                          : _ink,
                    ),
                    side: BorderSide(
                      color: sel
                          ? DesignTokens.figmaPinIconGreen
                          : const Color(0x4DBDCABA),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spaceLg),
          _SectionHeader(icon: Icons.spa_rounded, title: 'Health Benefits'),
          const SizedBox(height: 10),
          _HealthBenefitsBody(product: product),
          const SizedBox(height: DesignTokens.spaceLg),
          _SectionHeader(icon: Icons.restaurant_rounded, title: 'Cooking Tips'),
          const SizedBox(height: 10),
          Text(
            _cookingTipsCopy,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 23 / 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF3E4A3D),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          _CuratorCard(),
          const SizedBox(height: DesignTokens.spaceLg),
          Row(
            children: [
              Expanded(
                child: _AttributePill(
                  icon: Icons.eco_outlined,
                  label: 'NON-GMO',
                ),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _AttributePill(
                  icon: Icons.local_shipping_outlined,
                  label: 'LOCAL DELIVERY',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const String _cookingTipsCopy =
    'For the best umami release, sear on high heat with a splash of olive oil and sprig of thyme. Do not wash with water; instead, gently wipe with a damp cloth to preserve the delicate gill structure.';

class _HealthBenefitsBody extends StatelessWidget {
  const _HealthBenefitsBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.description != null && product.description!.trim().isNotEmpty) {
      return Text(
        product.description!,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 23 / 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF3E4A3D),
        ),
      );
    }
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 23 / 14,
          color: const Color(0xFF3E4A3D),
        ),
        children: const [
          TextSpan(
            text:
                'Renowned for their smoky flavor and rich texture, Shiitakes are nutritional powerhouses. They contain ',
          ),
          TextSpan(
            text: 'Lentinan',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text:
                ', a natural compound that supports the immune system, and are an excellent source of Vitamin D and essential B-vitamins.',
          ),
        ],
      ),
    );
  }
}

class _MetaPriceBlock extends StatelessWidget {
  const _MetaPriceBlock({required this.product, required this.variant});

  final Product product;
  final ProductVariant variant;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final titleStyle = GoogleFonts.manrope(
          fontSize: compact ? 32 : 36,
          height: compact ? 36 / 32 : 40 / 36,
          fontWeight: FontWeight.w800,
          letterSpacing: compact ? -0.7 : -0.9,
          color: DesignTokens.figmaSectionInk,
        );
        final priceBlock = Column(
          crossAxisAlignment:
              compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatInrMinor(variant.priceMinor),
              style: GoogleFonts.manrope(
                fontSize: 30,
                height: 36 / 30,
                fontWeight: FontWeight.w700,
                color: _ProductDetailPageState._priceGreen,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'PER ${variant.label.toUpperCase()}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: compact ? TextAlign.start : TextAlign.end,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  height: 15 / 10,
                  color: _ProductDetailPageState._metaGrey,
                ),
              ),
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2.5,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.figmaAccentLime,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'WOOD-GROWN',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  height: 15 / 10,
                  color: _ProductDetailPageState._priceGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (compact) ...[
              Text(
                product.name,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(height: DesignTokens.spaceSm),
              priceBlock,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  priceBlock,
                ],
              ),
          ],
        );
      },
    );
  }
}

class _RatingFreshnessRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFEAB308),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '4.8',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                  color: DesignTokens.figmaSectionInk,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '(124 reviews)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                    color: _ProductDetailPageState._metaGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0x4DBDCABA),
        ),
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FRESHNESS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 15 / 10,
                      color: _ProductDetailPageState._priceGreen,
                    ),
                  ),
                  Text(
                    '85%',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 15 / 10,
                      color: DesignTokens.figmaHeroCtaGreenAlt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: _ProductDetailPageState._freshnessTrack),
                      FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Container(
                          color: _ProductDetailPageState._priceGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _ProductDetailPageState._priceGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
            color: DesignTokens.figmaSectionInk,
          ),
        ),
      ],
    );
  }
}

class _CuratorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.figmaCategoryCard,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _ProductDetailPageState._borderTop),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&fit=crop&w=200&q=80',
            ),
            onBackgroundImageError: (_, __) {},
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURATED BY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 15 / 10,
                    color: _ProductDetailPageState._metaGrey,
                  ),
                ),
                Text(
                  'Farmer Marcus',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                    color: DesignTokens.figmaSectionInk,
                  ),
                ),
                Text(
                  'Green Valley Fungi, OR',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 16 / 12,
                    color: _ProductDetailPageState._body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributePill extends StatelessWidget {
  const _AttributePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: DesignTokens.figmaCategoryCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: _ProductDetailPageState._priceGreen),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 15 / 10,
              letterSpacing: 0.5,
              color: DesignTokens.figmaSectionInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DesignTokens.figmaSearchBarFill,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: _ProductDetailPageState._borderTop),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIconBtn(icon: Icons.remove, onPressed: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$qty',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
                color: DesignTokens.figmaSectionInk,
              ),
            ),
          ),
          _RoundIconBtn(icon: Icons.add, onPressed: onPlus),
        ],
      ),
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: icon == Icons.remove ? 14 : 14,
            color: onPressed == null
                ? DesignTokens.figmaNavInactive
                : DesignTokens.figmaSectionInk,
          ),
        ),
      ),
    );
  }
}

class _AddToCartGradientButton extends StatelessWidget {
  const _AddToCartGradientButton({
    required this.label,
    required this.onPressed,
    required this.inStock,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// False when variant is out of stock (grey chrome).
  final bool inStock;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final canTap = inStock && !busy && onPressed != null;
    final greenChrome = inStock;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: canTap ? onPressed : null,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            gradient: greenChrome
                ? const LinearGradient(
                    colors: [
                      DesignTokens.figmaHeroCtaGreen,
                      DesignTokens.figmaHeroCtaGreenAlt,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: greenChrome ? null : DesignTokens.figmaNavInactive,
            boxShadow: greenChrome
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
          child: busy && inStock
              ? const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: inStock ? Colors.white : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 28 / 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
