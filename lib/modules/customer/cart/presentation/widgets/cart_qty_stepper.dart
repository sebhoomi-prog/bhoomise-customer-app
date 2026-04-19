import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../domain/entities/cart_line.dart';
import '../cart_action_feedback.dart';
import '../controllers/cart_controller.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_variant.dart';

/// Compact − / count / + control — symmetric tap targets, [−] and [+] on the **outer**
/// edges of the pill (quick-commerce style).
class CartQtyStepper extends StatelessWidget {
  const CartQtyStepper({
    super.key,
    required this.product,
    required this.variant,
    required this.cart,
    this.dense = false,
    this.showActionFeedback = true,
    /// Blinkit-style home grid: green outline **ADD** when qty is 0.
    this.outlinedZeroAdd = false,
  });

  final Product product;
  final ProductVariant variant;
  final CartController cart;
  final bool dense;

  /// Floating snackbar + haptics when adding or changing qty (home, search, PDP).
  final bool showActionFeedback;
  final bool outlinedZeroAdd;

  double get _h => dense ? 36 : 40;
  double get _segment => dense ? 36 : 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      cart.cartVersion.value;
      final line = cart.lineForVariant(product.id, variant.id);
      final qty = line?.quantity ?? 0;
      final disabled = variant.isOutOfStock;

      if (qty <= 0) {
        Future<void> addOnce() async {
          await cart.addLine(
            CartLine(
              productId: product.id,
              variantId: variant.id,
              productName: product.name,
              variantLabel: variant.label,
              unitPriceMinor: variant.priceMinor,
              quantity: 1,
              imageUrl: product.imageUrl,
              variantGrams: variant.totalGrams,
            ),
          );
          if (showActionFeedback && context.mounted) {
            CartActionFeedback.notifyLineChange(
              context,
              product: product,
              variant: variant,
              cart: cart,
              delta: 1,
            );
          }
        }

        const kBlinkitGreen = Color(0xFF006B2C);
        final h = outlinedZeroAdd ? 30.0 : _h;

        if (outlinedZeroAdd) {
          return SizedBox(
            height: h,
            child: OutlinedButton(
              onPressed: disabled ? null : () async => addOnce(),
              style: OutlinedButton.styleFrom(
                foregroundColor: kBlinkitGreen,
                side: const BorderSide(color: kBlinkitGreen, width: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                minimumSize: const Size(60, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                'ADD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 16 / 12,
                  color: disabled
                      ? scheme.onSurface.withValues(alpha: 0.38)
                      : kBlinkitGreen,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: _h,
          child: FilledButton.tonal(
            onPressed: disabled ? null : () async => addOnce(),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, _h),
              maximumSize: Size(double.infinity, _h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(
                horizontal: dense ? 14 : 16,
                vertical: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_h / 2),
              ),
            ),
            child: Text(
              AppStrings.addToCart,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: dense ? 11.5 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }

      final effectiveLine = line!;
      return SizedBox(
        height: _h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(_h / 2),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepperSideButton(
                icon: Icons.remove,
                width: _segment,
                height: _h,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(_h / 2),
                ),
                onPressed: () async {
                  if (effectiveLine.quantity <= 1) {
                    await cart.remove(effectiveLine);
                    if (showActionFeedback && context.mounted) {
                      CartActionFeedback.notifyLineChange(
                        context,
                        product: product,
                        variant: variant,
                        cart: cart,
                        delta: -1,
                      );
                    }
                  } else {
                    await cart.decrement(effectiveLine);
                    if (showActionFeedback && context.mounted) {
                      CartActionFeedback.notifyLineChange(
                        context,
                        product: product,
                        variant: variant,
                        cart: cart,
                        delta: -1,
                      );
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 22),
                    child: Text(
                      '$qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: dense ? 14 : 15,
                        height: 1,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              _StepperSideButton(
                icon: Icons.add,
                width: _segment,
                height: _h,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(_h / 2),
                ),
                onPressed: disabled
                    ? null
                    : () async {
                        await cart.increment(effectiveLine);
                        if (showActionFeedback && context.mounted) {
                          CartActionFeedback.notifyLineChange(
                            context,
                            product: product,
                            variant: variant,
                            cart: cart,
                            delta: 1,
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// [−] / [+] aligned to the **outer** curves of the pill; full-height ink splash.
class _StepperSideButton extends StatelessWidget {
  const _StepperSideButton({
    required this.icon,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.onPressed,
  });

  final IconData icon;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Icon(
              icon,
              size: height <= 36 ? 17 : 19,
              color: onPressed == null
                  ? scheme.onSurface.withValues(alpha: 0.28)
                  : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
