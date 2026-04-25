import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../bloc/cart/index.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../data/coupon_catalog_service.dart';
import '../../domain/coupon_catalog_entry.dart';
import '../apply_cart_coupon.dart';

/// Full-screen coupon browser — Figma **Available Coupons** (filters + apply).
class AvailableCouponsPage extends StatefulWidget {
  const AvailableCouponsPage({super.key});

  @override
  State<AvailableCouponsPage> createState() => _AvailableCouponsPageState();
}

class _AvailableCouponsPageState extends State<AvailableCouponsPage> {
  late Future<List<CouponCatalogEntry>> _load;
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _load = Get.find<CouponCatalogService>().fetchAllCatalogEntries();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _expiryLine(CouponCatalogEntry e) {
    if (e.expiresAt == null) return AppStrings.couponNoExpiry;
    if (e.isExpired) return AppStrings.couponExpired;
    final d = e.expiresAt!;
    final diff = d.difference(DateTime.now());
    if (diff.inHours < 48 && diff.inHours >= 0) {
      final h = diff.inHours.clamp(1, 47);
      return AppStrings.couponExpiresInHours(h);
    }
    return AppStrings.couponExpiresOn(_formatDate(d));
  }

  List<CouponCatalogEntry> _filtered(List<CouponCatalogEntry> all) {
    switch (_filterIndex) {
      case 1:
        return all.where((e) => e.isUsable).toList();
      case 2:
        return all.where((e) => e.isExpiringSoon).toList();
      default:
        return all;
    }
  }

  Color _badgeBg(String label) {
    final h = label.hashCode.abs();
    final candidates = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFF1F8E9),
      const Color(0xFFE0F2F1),
    ];
    return candidates[h % candidates.length];
  }

  Color _badgeFg(String label) {
    final h = label.hashCode.abs();
    final candidates = [
      const Color(0xFF2E7D32),
      const Color(0xFF1565C0),
      const Color(0xFF33691E),
      const Color(0xFF00695C),
    ];
    return candidates[h % candidates.length];
  }

  Future<void> _apply(CouponCatalogEntry entry) async {
    final cart = context.read<CartBloc>().state;
    final out = await applyCouponCodeToCart(
      cart: cart,
      rawCode: entry.offer.code,
    );
    if (!mounted) return;
    if (!out.isSuccess) {
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
    Get.back(result: entry.offer.code);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: FutureBuilder<List<CouponCatalogEntry>>(
        future: _load,
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceLg,
                top + 120,
                DesignTokens.spaceLg,
                48,
              ),
              child: Text(
                AppStrings.couponCatalogLoadFailed,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: DesignTokens.figmaLabelMuted),
              ),
            );
          }
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: top + 80),
                child: const CircularProgressIndicator(
                  color: DesignTokens.figmaHeroCtaGreen,
                ),
              ),
            );
          }
          final all = snap.data ?? [];
          final list = _filtered(all);

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      DesignTokens.spaceLg,
                      top + 72 + DesignTokens.spaceLg,
                      DesignTokens.spaceLg,
                      MediaQuery.paddingOf(context).bottom + 120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HeroBanner(),
                        const SizedBox(height: DesignTokens.spaceMd),
                        _FilterRow(
                          selectedIndex: _filterIndex,
                          onChanged: (i) => setState(() => _filterIndex = i),
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text(
                                all.isEmpty
                                    ? AppStrings.couponsCatalogEmpty
                                    : AppStrings.couponsEmptyFilter,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: DesignTokens.figmaLabelMuted,
                                ),
                              ),
                            ),
                          )
                        else
                          ...list.expand(
                            (e) => [
                              _CouponCard(
                                entry: e,
                                badgeBg: _badgeBg(e.badgeLabel),
                                badgeFg: _badgeFg(e.badgeLabel),
                                expiryLine: _expiryLine(e),
                                expiryUrgent:
                                    e.isExpiringSoon || e.isExpired,
                                onApply: () => _apply(e),
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),
                            ],
                          ),
                        _ReferralCard(),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _FrostedTopBar(title: AppStrings.availableCouponsTitle),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FrostedTopBar extends StatelessWidget {
  const _FrostedTopBar({required this.title});

  final String title;

  static const double _slot = 56;

  @override
  Widget build(BuildContext context) {
    final canPop = routeCanPop(context);
    final scheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: DesignTokens.figmaHeaderFrostTint.withValues(alpha: 0.85),
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spaceSm,
            MediaQuery.paddingOf(context).top + DesignTokens.spaceSm,
            DesignTokens.spaceSm,
            DesignTokens.spaceMd,
          ),
          child: Row(
            children: [
              SizedBox(
                width: canPop ? _slot : 0,
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
                  title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    color: DesignTokens.figmaDeliverGreen,
                  ),
                ),
              ),
              const SizedBox(width: _slot),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.customerHomeHeroRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B),
            DesignTokens.figmaHeroCtaGreen,
            DesignTokens.figmaHeroCtaGreenAlt,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.availableCouponsHeroKicker,
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 15 / 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: DesignTokens.figmaAccentLime.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.availableCouponsTitle,
            style: GoogleFonts.manrope(
              fontSize: 28,
              height: 32 / 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.availableCouponsSubtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.filterCouponsAll,
      AppStrings.filterCouponsActive,
      AppStrings.filterCouponsExpiring,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final on = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
            child: Material(
              color: on
                  ? DesignTokens.figmaHeroCtaGreen
                  : const Color(0xFFE8EAF0),
              borderRadius: BorderRadius.circular(9999),
              child: InkWell(
                borderRadius: BorderRadius.circular(9999),
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : DesignTokens.figmaSectionInk,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.entry,
    required this.badgeBg,
    required this.badgeFg,
    required this.expiryLine,
    required this.expiryUrgent,
    required this.onApply,
  });

  final CouponCatalogEntry entry;
  final Color badgeBg;
  final Color badgeFg;
  final String expiryLine;
  final bool expiryUrgent;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final pct = entry.offer.percentOff;
    final usable = entry.isUsable && entry.offer.active;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.badgeLabel.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 15 / 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: badgeFg,
                    ),
                  ),
                ),
              ),
              Text(
                '$pct% OFF',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.figmaHeroCtaGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.offer.code,
            style: GoogleFonts.manrope(
              fontSize: 20,
              height: 26 / 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: DesignTokens.figmaSectionInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 18 / 13,
              color: DesignTokens.figmaLabelMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: expiryUrgent
                    ? const Color(0xFFBA1A1A)
                    : DesignTokens.figmaLabelMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  expiryLine,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: expiryUrgent
                        ? const Color(0xFFBA1A1A)
                        : DesignTokens.figmaStoreMeta,
                  ),
                ),
              ),
              Material(
                color: usable
                    ? DesignTokens.figmaHeroCtaGreen
                    : DesignTokens.figmaNavInactive.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: usable ? onApply : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text(
                      AppStrings.apply,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 18 / 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: usable ? 1 : 0.7),
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

class _ReferralCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.figmaCategoryCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco_rounded,
            size: 36,
            color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.couponReferralTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: DesignTokens.figmaSectionInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.couponReferralBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 18 / 13,
              color: DesignTokens.figmaLabelMuted,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              AppStrings.couponReferralCta,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DesignTokens.figmaHeroCtaGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
