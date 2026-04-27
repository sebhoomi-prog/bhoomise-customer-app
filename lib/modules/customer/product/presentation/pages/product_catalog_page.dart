import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../bloc/cart/index.dart';
import '../../../../../bloc/product/index.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/utils/money.dart';
import '../../../../../core/widgets/customer_shell_background.dart';
import '../../../cart/presentation/widgets/cart_qty_stepper.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/extensions/product_pack_extensions.dart';

class ProductCatalogPage extends StatelessWidget {
  const ProductCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cartState = context.watch<CartBloc>().state;

    return CustomerShellBackground(
      child: SafeArea(
        child: BlocBuilder<ProductBloc, ProductBlocState>(
          builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: scheme.primary,
            onRefresh: () async =>
                context.read<ProductBloc>().add(const ProductRefreshRequested()),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: const Color(0xFF15803D),
                        ),
                        Expanded(
                          child: Text(
                            'Organic Curator',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF166534),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.find<CartBloc>().add(const CartLoadRequested());
                          },
                          icon: Badge(
                            isLabelVisible: cartState.totalItemQuantity > 0,
                            label: Text('${cartState.totalItemQuantity}'),
                            child: const Icon(Icons.shopping_cart_outlined),
                          ),
                          color: const Color(0xFF15803D),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E3F6),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: Color(0xFF6E7B6C), size: 18),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search for mushrooms',
                              style: TextStyle(
                                color: Color(0x996E7B6C),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                  sliver: SliverToBoxAdapter(child: _SearchChipSection()),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                  sliver: SliverToBoxAdapter(child: _TrendingSearchesSection()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Results for "Mushroom"',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF121C2A),
                                ),
                          ),
                        ),
                        Text(
                          '${state.products.length} items found',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6E7B6C),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 304,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.products[index];
                        return _SearchProductCard(product: product);
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SearchChipSection extends StatelessWidget {
  const _SearchChipSection();

  @override
  Widget build(BuildContext context) {
    const chips = ['Lion\'s Mane', 'Oyster', 'Morels'];
    final chipWidgets = chips.map<Widget>((chip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          chip,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF121C2A),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'RECENT SEARCHES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: Color(0xFF6E7B6C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: chipWidgets,
        ),
      ],
    );
  }
}

class _TrendingSearchesSection extends StatelessWidget {
  const _TrendingSearchesSection();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String title) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x1A767565),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF5D5D4E), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF121C2A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF6E7B6C)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'TRENDING SEARCHES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: Color(0xFF6E7B6C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        row(Icons.trending_up_rounded, 'Wild Harvested Porcini'),
        const SizedBox(height: 4),
        row(Icons.spa_outlined, 'Medicinal Tinctures'),
      ],
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final v = product.preferredListVariant;
    if (v == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFF94A3B8),
                              size: 32,
                            ),
                          )
                        : const Icon(
                            Icons.eco_rounded,
                            color: Color(0xFF94A3B8),
                            size: 42,
                          ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xE6FFFFFF),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 11.7, color: Color(0xFF006B2C)),
                          SizedBox(width: 4),
                          Text(
                            '12 MINS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.25,
                              color: Color(0xFF121C2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121C2A),
              ),
            ),
            Text(
              v.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
                color: Color(0xFF6E7B6C),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatInrMinor(v.priceMinor),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF006B2C),
                    ),
                  ),
                ),
                _AddButton(product: product, variant: v),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product, required this.variant});
  final Product product;
  final ProductVariant variant;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: CartQtyStepper(
        product: product,
        variant: variant,
        dense: true,
        compact: true,
      ),
    );
  }
}
