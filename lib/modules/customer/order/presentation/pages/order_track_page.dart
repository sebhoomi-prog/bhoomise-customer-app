import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../core/theme/design_tokens.dart';
const _kInk = DesignTokens.figmaSectionInk;
const _kSlate = Color(0xFF596373);
const _kLineMuted = Color(0x4DBDCABA);
const _kPendingFill = DesignTokens.figmaSearchBarFill;

/// Customer order tracking — Figma: live ETA, map, courier, timeline, share CTA.
class OrderTrackPage extends StatelessWidget {
  const OrderTrackPage({super.key});

  String _orderId() {
    final a = Get.arguments;
    if (a is String && a.isNotEmpty) return a;
    if (a is Map && a['orderId'] is String) {
      return (a['orderId'] as String).trim();
    }
    return 'SH-9921';
  }

  @override
  Widget build(BuildContext context) {
    final orderId = _orderId();
    final topPad = MediaQuery.paddingOf(context).top + 72;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 104;

    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              DesignTokens.spaceLg,
              topPad,
              DesignTokens.spaceLg,
              bottomPad,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EtaBlock(),
                const SizedBox(height: DesignTokens.spaceLg),
                _SourceDestinationRow(),
                const SizedBox(height: DesignTokens.spaceLg),
                _MapPanel(),
                const SizedBox(height: DesignTokens.spaceLg),
                _CourierCard(),
                const SizedBox(height: DesignTokens.spaceLg),
                _OrderTimeline(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TrackingHeader(orderLabel: AppStrings.orderNumber(orderId)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ShareTrackingFooter(
              orderId: orderId,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.orderLabel});

  final String orderLabel;

  /// Matches [ProductCatalogPage] toolbar slots so the title stays centered.
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
                  orderLabel,
                  textAlign: TextAlign.center,
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

class _EtaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.currentStatusLabel,
          style: GoogleFonts.inter(
            fontSize: 10,
            height: 15 / 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: DesignTokens.figmaStoreMeta,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.arrivingInMinutes(12),
          style: GoogleFonts.manrope(
            fontSize: 30,
            height: 36 / 30,
            fontWeight: FontWeight.w800,
            color: _kInk,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceLg),
        const _DeliveryProgressBar(progress: 0.7),
      ],
    );
  }
}

class _DeliveryProgressBar extends StatelessWidget {
  const _DeliveryProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final fillW = w * progress;
        final thumbLeft = (fillW - 10).clamp(0.0, w - 20);
        return SizedBox(
          height: 20,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: DesignTokens.figmaSearchBarFill,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [
                          DesignTokens.figmaHeroCtaGreen,
                          DesignTokens.figmaHeroCtaGreenAlt,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: thumbLeft,
                top: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignTokens.figmaHeroCtaGreen,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SourceDestinationRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _EndpointCard(
            icon: Icons.restaurant_rounded,
            iconColor: DesignTokens.figmaHeroCtaGreen,
            label: AppStrings.sourceLabel,
            title: AppStrings.orderTrackSourceName,
          ),
        ),
        const SizedBox(width: DesignTokens.spaceSm),
        Expanded(
          child: _EndpointCard(
            icon: Icons.location_on_rounded,
            iconColor: DesignTokens.figmaStoreMeta,
            label: AppStrings.destinationLabel,
            title: AppStrings.orderTrackDestinationName,
          ),
        ),
      ],
    );
  }
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 15 / 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: SizedBox(
        height: 320,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade400,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.05),
              ),
            ),
            CustomPaint(painter: _MapGridPainter()),
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.22,
              top: 320 * 0.34,
              child: _CourierMapMarker(),
            ),
            Positioned(
              right: MediaQuery.sizeOf(context).width * 0.08,
              bottom: 320 * 0.24,
              child: _YouPill(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light street grid suggestion.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CourierMapMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.figmaHeroCtaGreen,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.two_wheeler_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _YouPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kInk,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_rounded,
            size: 14,
            color: DesignTokens.figmaAccentLime,
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.youMarker,
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 15 / 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.figmaCategoryCard,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1580489944761-15a19d654956?fm=jpg&fit=crop&w=200&q=80',
            ),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.orderTrackCourierName,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFEAB308),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        AppStrings.orderTrackCourierMeta,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w400,
                          color: _kSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Material(
                color: Colors.white,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.chatCourierSoon)),
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: DesignTokens.figmaHeroCtaGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: DesignTokens.figmaHeroCtaGreen,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.callCourierSoon)),
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 20,
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

class _OrderTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = <_TimelineEntry>[
      _TimelineEntry(
        kind: _TimelineDotKind.done,
        title: AppStrings.timelineOrderPlaced,
        subtitle: AppStrings.timelineOrderPlacedDetail,
      ),
      _TimelineEntry(
        kind: _TimelineDotKind.done,
        title: AppStrings.timelinePreparing,
        subtitle: AppStrings.timelinePreparingDetail,
      ),
      _TimelineEntry(
        kind: _TimelineDotKind.active,
        title: AppStrings.timelineOutForDelivery,
        subtitle: AppStrings.timelineOutForDeliveryDetail,
        titleGreen: true,
        subtitleWeight: FontWeight.w500,
      ),
      _TimelineEntry(
        kind: _TimelineDotKind.pending,
        title: AppStrings.timelineDelivered,
        subtitle: AppStrings.timelineDeliveredDetail,
        faded: true,
      ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 11,
          top: 20,
          bottom: 20,
          child: Container(
            width: 2,
            color: _kLineMuted,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(items.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 32),
              child: _TimelineRow(entry: items[i]),
            );
          }),
        ),
      ],
    );
  }
}

enum _TimelineDotKind { done, active, pending }

class _TimelineEntry {
  const _TimelineEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.titleGreen = false,
    this.subtitleWeight = FontWeight.w400,
    this.faded = false,
  });

  final _TimelineDotKind kind;
  final String title;
  final String subtitle;
  final bool titleGreen;
  final FontWeight subtitleWeight;
  final bool faded;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final _TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final opacity = entry.faded ? 0.4 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Dot(kind: entry.kind),
          const SizedBox(width: DesignTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: entry.kind == _TimelineDotKind.active
                        ? FontWeight.w800
                        : FontWeight.w700,
                    color: entry.titleGreen
                        ? DesignTokens.figmaDeliverGreen
                        : _kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: entry.subtitleWeight,
                    color: _kSlate,
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

class _Dot extends StatelessWidget {
  const _Dot({required this.kind});

  final _TimelineDotKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _TimelineDotKind.done:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: DesignTokens.figmaHeroCtaGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case _TimelineDotKind.active:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: DesignTokens.figmaAccentLime,
            shape: BoxShape.circle,
            border: Border.all(
              color: DesignTokens.figmaHeroCtaGreen,
              width: 4,
            ),
          ),
        );
      case _TimelineDotKind.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _kPendingFill,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBDCABA), width: 2),
          ),
        );
    }
  }
}

class _ShareTrackingFooter extends StatelessWidget {
  const _ShareTrackingFooter({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            DesignTokens.spaceLg,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          color: Colors.white.withValues(alpha: 0.7),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () async {
                final link = 'https://bhoomise.app/track/$orderId';
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.shareTrackingReady)),
                  );
                }
              },
              child: Ink(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [
                      DesignTokens.figmaHeroCtaGreen,
                      DesignTokens.figmaHeroCtaGreenAlt,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.figmaHeroCtaGreen.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: DesignTokens.figmaHeroCtaGreen.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AppStrings.shareTrackingLink,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
