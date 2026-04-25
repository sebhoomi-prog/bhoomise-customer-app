import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../navigation/customer_shell_navigation.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/figma_typography.dart';
import '../../../../core/widgets/section_header.dart';
import 'widgets/figma/customer_category_grid.dart';
import 'widgets/figma/customer_fresh_arrivals.dart';
import 'widgets/figma/customer_hero_carousel.dart';
import 'widgets/figma/customer_home_header.dart';
import 'widgets/figma/customer_search_pill.dart';

/// Customer **Home** tab — Figma Customer Home (`9:3`) + frosted header (CSS export).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final referral = Get.arguments is Map
        ? (Get.arguments as Map)['referral'] as String?
        : null;

    final headerTop = DesignTokens.customerHomeHeaderExtent(context);

    return Scaffold(
      backgroundColor: DesignTokens.figmaCustomerShellBg,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  DesignTokens.spaceLg,
                  headerTop,
                  DesignTokens.spaceLg,
                  DesignTokens.spaceSm,
                ),
                sliver: SliverToBoxAdapter(
                  child: CustomerSearchPill(
                    onTap: CustomerSearchPill.openCatalog(),
                  ),
                ),
              ),
              if (referral != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spaceLg,
                    DesignTokens.spaceMd,
                    DesignTokens.spaceLg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      color: scheme.primaryContainer.withValues(alpha: 0.85),
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMd),
                        child: Row(
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              color: scheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: DesignTokens.spaceSm),
                            Expanded(
                              child: Text(
                                'Referral: $referral',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: DesignTokens.spaceLg),
              ),
              const SliverToBoxAdapter(child: CustomerHeroCarousel()),
              const SliverToBoxAdapter(
                child: SizedBox(height: DesignTokens.spaceLg),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.homeCategoriesTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FigmaTypography.customerSectionH3(
                            DesignTokens.figmaSectionInk,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.only(left: 8),
                        ),
                        onPressed: () => CustomerShellNavigation.goSearch(),
                        child: Text(
                          AppStrings.homeCategoriesViewAll,
                          style: FigmaTypography.customerViewAllLink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: DesignTokens.spaceSm),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
                sliver: SliverToBoxAdapter(child: CustomerCategoryGrid()),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: DesignTokens.spaceLg),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.homeFreshArrivalsTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FigmaTypography.customerSectionH3(
                            DesignTokens.figmaSectionInk,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.only(left: 8),
                        ),
                        onPressed: () => CustomerShellNavigation.goSearch(),
                        child: Text(
                          AppStrings.homeFreshHarvestSeeAll,
                          style: FigmaTypography.customerViewAllLink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: DesignTokens.spaceSm),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceLg,
                  0,
                  DesignTokens.spaceLg,
                  DesignTokens.spaceMd,
                ),
                sliver: const SliverToBoxAdapter(
                  child: CustomerFreshArrivalsBlock(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceLg,
                  0,
                  DesignTokens.spaceLg,
                  DesignTokens.spaceXl,
                ),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppStrings.savedAddresses,
                    subtitle: AppStrings.savedAddressesCardSubtitle,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceLg,
                  0,
                  DesignTokens.spaceLg,
                  DesignTokens.spaceXl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Material(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLg),
                      onTap: () => Get.toNamed(AppRoutes.addresses),
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spaceMd),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: scheme.primary),
                            const SizedBox(width: DesignTokens.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.savedAddresses,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    AppStrings.homeAddressesSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: scheme.outline),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                  width: double.infinity,
                  color:
                      DesignTokens.figmaHeaderFrostTint.withValues(alpha: 0.7),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 16,
                    left: DesignTokens.spaceLg,
                    right: DesignTokens.spaceLg,
                    bottom: 16,
                  ),
                  child: CustomerHomeFigmaHeader(
                    onProfileTap: () => Get.toNamed(AppRoutes.profileEdit),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
