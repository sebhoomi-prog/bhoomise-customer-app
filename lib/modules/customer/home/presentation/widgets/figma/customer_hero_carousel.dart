import 'package:flutter/material.dart';

import '../../../../../../core/theme/design_tokens.dart';
import '../../../../../../core/theme/figma_typography.dart';
import '../../../../navigation/customer_shell_navigation.dart';

/// Hero offers — 192px cards, 32px radius, photo + left gradient (Figma CSS).
class CustomerHeroCarousel extends StatefulWidget {
  const CustomerHeroCarousel({super.key});

  @override
  State<CustomerHeroCarousel> createState() => _CustomerHeroCarouselState();
}

class _CustomerHeroCarouselState extends State<CustomerHeroCarousel> {
  final _controller = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 208,
      child: PageView(
        controller: _controller,
        children: [
          _CustomerHeroSlide(
            badge: 'SEASONAL SPECIAL',
            title: "20% Off Lion's Mane",
            imageUrl:
                'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?fm=jpg&fit=crop&w=900&q=80',
            scrim: LinearGradient(
              colors: [
                Color(0x99000000),
                Color(0x00000000),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            shopNowColor: DesignTokens.figmaHeroCtaGreen,
          ),
          _CustomerHeroSlide(
            badge: 'NEW ARRIVAL',
            title: 'Medicinal Extracts',
            imageUrl:
                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?fm=jpg&fit=crop&w=900&q=80',
            scrim: LinearGradient(
              colors: [
                Color(0x9914532D),
                Color(0x0014532D),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            shopNowColor: DesignTokens.figmaHeroCtaGreenAlt,
          ),
        ],
      ),
    );
  }
}

class _CustomerHeroSlide extends StatelessWidget {
  const _CustomerHeroSlide({
    required this.badge,
    required this.title,
    required this.imageUrl,
    required this.scrim,
    required this.shopNowColor,
  });

  final String badge;
  final String title;
  final String imageUrl;
  final Gradient scrim;
  final Color shopNowColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: DesignTokens.spaceSm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.customerHomeHeroRadius),
        child: SizedBox(
          height: 192,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.eco_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              DecoratedBox(decoration: BoxDecoration(gradient: scrim)),
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(badge, style: FigmaTypography.heroBadgeLime()),
                    const SizedBox(height: DesignTokens.spaceSm),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: FigmaTypography.heroHeadlineWhite(),
                    ),
                    const SizedBox(height: DesignTokens.spaceMd),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: shopNowColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLg,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: CustomerShellNavigation.goSearch,
                      child: Text('Shop Now', style: FigmaTypography.heroShopNow()),
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
}
