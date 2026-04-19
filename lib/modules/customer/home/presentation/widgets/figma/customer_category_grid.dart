import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../navigation/customer_shell_navigation.dart';
import '../../../../../../core/theme/design_tokens.dart';
import '../../../../../../core/theme/figma_typography.dart';
import '../../../../../../core/util/unsplash_raster_url.dart';
import '../../controllers/home_controller.dart';
import '../../../domain/customer_home_category.dart';

/// 2×2 category tiles — `#EFF4FF`, 48px radius; data from Firestore (`app/customer_home`).
class CustomerCategoryGrid extends GetView<HomeController> {
  const CustomerCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.homeCategories;
      if (items.isEmpty) {
        return SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }
      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: DesignTokens.spaceMd,
        crossAxisSpacing: DesignTokens.spaceMd,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // Slightly taller tiles so title/subtitle + image never clip on small phones.
        childAspectRatio: 0.82,
        children: items
            .map(
              (c) => _CustomerCategoryCard(
                item: c,
                onTap: CustomerShellNavigation.goSearch,
              ),
            )
            .toList(),
      );
    });
  }
}

class _CustomerCategoryCard extends StatelessWidget {
  const _CustomerCategoryCard({
    required this.item,
    required this.onTap,
  });

  final CustomerHomeCategory item;
  final VoidCallback onTap;

  static final _radius = BorderRadius.circular(
    DesignTokens.customerHomeCategoryRadius,
  );

  String _imageUrlForDecode(String url) {
    final u = url.trim().toLowerCase();
    if (u.startsWith('https://images.unsplash.com')) {
      return unsplashAsJpeg(url.trim());
    }
    return url.trim();
  }

  @override
  Widget build(BuildContext context) {
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: DesignTokens.figmaCategoryCard,
      borderRadius: _radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceLg,
                DesignTokens.spaceLg,
                DesignTokens.spaceLg,
                DesignTokens.spaceSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FigmaTypography.categoryNameFigma(
                      DesignTokens.figmaCategoryNameGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FigmaTypography.categorySubtitleFigma(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.tagline,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: variant,
                          height: 1.35,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: _radius.bottomLeft,
                  bottomRight: _radius.bottomRight,
                ),
                child: Image.network(
                  _imageUrlForDecode(item.imageUrl),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 40,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return ColoredBox(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
