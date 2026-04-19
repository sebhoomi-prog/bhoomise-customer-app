import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../navigation/customer_shell_navigation.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../domain/entities/delivery_address.dart';
import '../controllers/address_list_controller.dart';

const _kSlate = Color(0xFF555F6F);
const _kWorkIconBg = Color(0xFFD6E0F3);
const _kLogisticsBg = Color(0x33E5E3D0);

/// Customer delivery address picker — Figma: bento cards, logistics snippet, CTA.
class AddressListPage extends GetView<AddressListController> {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            if (controller.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.spaceLg,
                    MediaQuery.paddingOf(context).top + 96,
                    DesignTokens.spaceLg,
                    MediaQuery.paddingOf(context).bottom + 140,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        AppStrings.selectDeliveryAddress,
                        style: GoogleFonts.manrope(
                          fontSize: 36,
                          height: 45 / 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.9,
                          color: DesignTokens.figmaSectionInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.selectDeliverySubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w400,
                          color: _kSlate,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (controller.addresses.isEmpty)
                        _EmptyAddressHint(onAdd: () => _openForm(context))
                      else ...[
                        ...controller.addresses.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _AddressBentoCard(
                              address: a,
                              selected: controller.selectedDeliveryId.value == a.id,
                              onSelect: () => controller.selectAddress(a),
                              onEdit: () => Get.toNamed(
                                AppRoutes.addressForm,
                                arguments: a,
                              ),
                              onDelete: () => _confirmDelete(context, a),
                            ),
                          ),
                        ),
                        _AddAddressDashedCard(
                          onTap: () => _openForm(context),
                        ),
                        const SizedBox(height: 16),
                        const _LogisticsPurityCard(),
                        const SizedBox(height: 16),
                        const _MapDecorationStrip(),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          }),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AddressListHeader(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              final list = controller.addresses;
              if (list.isEmpty) return const SizedBox.shrink();
              final sel = controller.selectedDeliveryId.value;
              DeliveryAddress? selected;
              if (sel != null) {
                for (final a in list) {
                  if (a.id == sel) {
                    selected = a;
                    break;
                  }
                }
              }
              return _DeliverFooter(
                enabled: selected != null,
                onDeliver: () {
                  if (selected == null) return;
                  if (Navigator.of(context).canPop()) {
                    Get.back(result: selected);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppStrings.deliverHerePlaceOrder}: ${selected.recipientName}',
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Get.toNamed(AppRoutes.addressForm);
  }

  Future<void> _confirmDelete(BuildContext context, DeliveryAddress a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteAddress),
        content: const Text(AppStrings.deleteAddressConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok == true) await controller.delete(a);
  }
}

class _AddressListHeader extends StatelessWidget {
  const _AddressListHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: DesignTokens.figmaHeaderFrostTint.withValues(alpha: 0.7),
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            MediaQuery.paddingOf(context).top + 8,
            DesignTokens.spaceLg,
            16,
          ),
          child: Row(
            children: [
              adaptiveFrostedBackControl(
                context,
                iconColor: DesignTokens.figmaDeliverGreen,
                iconSize: 16,
              ),
              SizedBox(width: routeCanPop(context) ? 16 : 0),
              const Spacer(),
              IconButton(
                onPressed: CustomerShellNavigation.goCart,
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: DesignTokens.figmaLabelMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAddressHint extends StatelessWidget {
  const _EmptyAddressHint({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.noSavedAddresses,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 24 / 16,
            color: _kSlate,
          ),
        ),
        const SizedBox(height: 24),
        _AddAddressDashedCard(onTap: onAdd),
        const SizedBox(height: 16),
        const _LogisticsPurityCard(),
        const SizedBox(height: 16),
        const _MapDecorationStrip(),
      ],
    );
  }
}

class _AddressBentoCard extends StatelessWidget {
  const _AddressBentoCard({
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final DeliveryAddress address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _homeLike =>
      address.label.toLowerCase().contains('home') ||
      address.label == AppStrings.labelHome;

  @override
  Widget build(BuildContext context) {
    final active = selected;
    final phoneColor =
        active ? DesignTokens.figmaHeroCtaGreen : _kSlate;
    final phoneWeight = active ? FontWeight.w500 : FontWeight.w500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onSelect,
        child: Ink(
          decoration: BoxDecoration(
            color: active ? DesignTokens.figmaCategoryCard : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              width: 2,
              color: active
                  ? DesignTokens.figmaHeroCtaGreenAlt
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.figmaSectionInk.withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: active
                                    ? DesignTokens.figmaHeroCtaGreenAlt
                                    : _kWorkIconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _homeLike
                                    ? Icons.home_rounded
                                    : Icons.work_outline_rounded,
                                size: 12,
                                color: active
                                    ? const Color(0xFFF7FFF2)
                                    : const Color(0xFF596373),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? DesignTokens.figmaAccentLime
                                        .withValues(alpha: 0.3)
                                    : DesignTokens.figmaSearchBarFill
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                address.label.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  height: 15 / 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: active
                                      ? DesignTokens.figmaHeroCtaGreen
                                      : _kSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: DesignTokens.figmaLabelMuted,
                          ),
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text(AppStrings.editAddress),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(AppStrings.delete),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        _RadioDot(selected: active),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      address.recipientName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        height: 28 / 18,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.figmaSectionInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _addressBlock(address),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 26 / 16,
                        fontWeight: FontWeight.w400,
                        color: _kSlate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_in_talk_rounded,
                          size: 12,
                          color: phoneColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPhoneDisplay(address.phone),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: phoneWeight,
                            color: phoneColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -22,
                bottom: -22,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(
                    Icons.local_florist_rounded,
                    size: 96,
                    color: DesignTokens.figmaSectionInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _addressBlock(DeliveryAddress a) {
    final line2 =
        (a.line2 != null && a.line2!.trim().isNotEmpty) ? '${a.line2!}, ' : '';
    return '${a.line1}, $line2${a.city}, ${a.state} ${a.pincode}';
  }

  String _formatPhoneDisplay(String p) {
    final d = p.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10) {
      return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6)}';
    }
    return p;
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFBDCABA),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DesignTokens.figmaHeroCtaGreen,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _AddAddressDashedCard extends StatelessWidget {
  const _AddAddressDashedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: const Color(0xFFBDCABA),
            strokeWidth: 2,
            radius: 32,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDEE9FC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: DesignTokens.figmaHeroCtaGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.addNewAddressTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.figmaSectionInk,
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

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics(forceClosed: true)) {
      var d = 0.0;
      while (d < metric.length) {
        final e = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, e), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

class _LogisticsPurityCard extends StatelessWidget {
  const _LogisticsPurityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: _kLogisticsBg,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.logisticsPurity,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: DesignTokens.figmaStoreMeta,
                ),
              ),
              Text(
                AppStrings.freshnessScoreHigh,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.figmaHeroCtaGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: DesignTokens.figmaSearchBarFill),
                  FractionallySizedBox(
                    widthFactor: 0.98,
                    child: Container(
                      color: DesignTokens.figmaHeroCtaGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.logisticsPurityCaption,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 16 / 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF555F6F),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDecorationStrip extends StatelessWidget {
  const _MapDecorationStrip();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: SizedBox(
          height: 192,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?fm=jpg&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: DesignTokens.figmaCategoryCard,
                  child: Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.35),
                  ),
                ),
              ),
              ColoredBox(
                color: DesignTokens.figmaHeroCtaGreen.withValues(alpha: 0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliverFooter extends StatelessWidget {
  const _DeliverFooter({
    required this.enabled,
    required this.onDeliver,
  });

  final bool enabled;
  final VoidCallback onDeliver;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: DesignTokens.figmaHeaderFrostTint.withValues(alpha: 0.7),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.figmaSectionInk.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            DesignTokens.spaceLg,
            16,
            DesignTokens.spaceLg,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: enabled ? onDeliver : null,
              child: Ink(
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
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
                      AppStrings.deliverHerePlaceOrder,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        height: 28 / 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
