import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../navigation/customer_shell_navigation.dart';
import '../../../../../../bloc/home/index.dart';
import '../../../../../../core/theme/design_tokens.dart';
import '../../../../../../core/theme/figma_typography.dart';
import '../../../../../../core/util/unsplash_raster_url.dart';
import '../../../domain/customer_home_category.dart';

/// Horizontal circular category scroll — Figma home style.
class CustomerCategoryGrid extends StatelessWidget {
  const CustomerCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeBlocState>(
      builder: (context, state) {
        final items = state.categoriesOrDefault;
        if (items.isEmpty) {
          return SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.spaceMd),
            itemBuilder: (context, i) => _CustomerCategoryCard(
              item: items[i],
              onTap: CustomerShellNavigation.goSearch,
            ),
          ),
        );
      },
    );
  }
}

class _CustomerCategoryCard extends StatelessWidget {
  const _CustomerCategoryCard({required this.item, required this.onTap});

  final CustomerHomeCategory item;
  final VoidCallback onTap;

  String _imageUrlForDecode(String url) {
    final u = url.trim().toLowerCase();
    if (u.startsWith('https://images.unsplash.com')) {
      return unsplashAsJpeg(url.trim());
    }
    return url.trim();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignTokens.figmaCategoryCard,
                borderRadius: BorderRadius.circular(48),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _imageUrlForDecode(item.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.outline,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FigmaTypography.categorySubtitleFigma().copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
