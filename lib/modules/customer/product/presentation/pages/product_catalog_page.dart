import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/utils/money.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../core/widgets/customer_shell_background.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../navigation/customer_shell_navigation.dart';
import '../../../cart/presentation/widgets/cart_qty_stepper.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/extensions/product_pack_extensions.dart';
import '../controllers/product_list_controller.dart';

class ProductCatalogPage extends GetView<ProductListController> {
  const ProductCatalogPage({super.key});

  /// Match [leading] presence so the toolbar does not reserve empty leading space on the shell Search tab.
  static const double _kToolbarLeadingSlot = 56;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final scheme = Theme.of(context).colorScheme;
    final hasBack = routeCanPop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leadingWidth: hasBack ? _kToolbarLeadingSlot : 0,
        leading: adaptiveAppBarLeading(context),
        automaticallyImplyLeading: adaptiveAppBarImplyLeading(context),
        title: Text(
          AppStrings.navSearch,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            alignment: Alignment.center,
            tooltip: AppStrings.cart,
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spaceMd),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            iconSize: 24,
            icon: Obx(() {
              cart.cartVersion.value;
              final n = cart.totalItemQuantity;
              return Badge(
                label: Text('$n'),
                isLabelVisible: n > 0,
                backgroundColor: scheme.primary,
                textColor: scheme.onPrimary,
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: scheme.onSurface,
                  size: 24,
                ),
              );
            }),
            onPressed: CustomerShellNavigation.goCart,
          ),
        ],
      ),
      body: CustomerShellBackground(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Text(
                  controller.error.value!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: scheme.primary,
            onRefresh: controller.load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                DesignTokens.spaceMd,
                DesignTokens.spaceMd,
                DesignTokens.spaceXl,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                  child: _ProductCard(product: product),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: DesignTokens.softCard(context),
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            onTap: () => Get.toNamed(AppRoutes.productDetail, arguments: product),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.7),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Icon(Icons.eco_rounded, color: scheme.primary),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (product.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.description!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          'View details',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          const Divider(height: 1),
          const SizedBox(height: DesignTokens.spaceSm),
          ...product.variantsSortedByPack.map(
            (v) => _VariantRow(product: product, variant: v, cart: cart),
          ),
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.product,
    required this.variant,
    required this.cart,
  });

  final Product product;
  final ProductVariant variant;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String stockLabel() {
      if (variant.isOutOfStock) return 'Out of stock';
      if (variant.isLowStock) return 'Low stock (${variant.stock})';
      return 'In stock (${variant.stock})';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Text(
                    variant.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatInrMinor(variant.priceMinor)} · ${stockLabel()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: variant.isLowStock && !variant.isOutOfStock
                            ? scheme.tertiary
                            : scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          CartQtyStepper(
            product: product,
            variant: variant,
            cart: cart,
          ),
        ],
      ),
    );
  }
}
