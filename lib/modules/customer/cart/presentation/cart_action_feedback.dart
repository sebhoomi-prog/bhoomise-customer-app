import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../product/domain/entities/product.dart';
import '../../product/domain/entities/product_variant.dart';
import 'controllers/cart_controller.dart';

/// Snackbar + haptics so adds from home/search feel like a polished quick-commerce app.
class CartActionFeedback {
  CartActionFeedback._();

  static String _shortLabel(String name, [int max = 30]) {
    final t = name.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max - 1)}…';
  }

  /// Call after cart mutations from [CartQtyStepper] (mounted [context] required).
  static void notifyLineChange(
    BuildContext context, {
    required Product product,
    required ProductVariant variant,
    required CartController cart,
    required int delta,
  }) {
    if (!context.mounted) return;
    final line = cart.lineForVariant(product.id, variant.id);
    final bagTotal = cart.totalItemQuantity;

    if (delta < 0 && line == null) {
      HapticFeedback.selectionClick();
      _showSnack(
        context,
        title: AppStrings.cartFeedbackRemoved(_shortLabel(product.name)),
        subtitle:
            bagTotal > 0 ? AppStrings.cartItemsStillInBag(bagTotal) : null,
        positive: false,
      );
      return;
    }

    if (delta > 0) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    final lineQty = line?.quantity ?? 0;
    final title = AppStrings.cartFeedbackDeltaTitle(
      delta,
      _shortLabel(product.name),
    );
    final subtitle =
        lineQty > 0 ? AppStrings.cartFeedbackLineAndBag(lineQty, bagTotal) : null;

    _showSnack(
      context,
      title: title,
      subtitle: subtitle,
      positive: delta >= 0,
    );
  }

  static void _showSnack(
    BuildContext context, {
    required String title,
    String? subtitle,
    required bool positive,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 72),
        duration: const Duration(milliseconds: 1700),
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: scheme.inverseSurface.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              positive ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
              color: positive
                  ? DesignTokens.figmaHeroCtaGreen
                  : scheme.onInverseSurface.withValues(alpha: 0.85),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      height: 20 / 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: scheme.onInverseSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onInverseSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
