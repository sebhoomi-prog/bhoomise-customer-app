import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_tokens.dart';

/// Frosted bottom bar — Figma Customer Home: mint active pill, slate inactive.
class BhoomiseRoleBottomNav extends StatelessWidget {
  const BhoomiseRoleBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BhoomiseBottomNavItem> items;

  static const _active = DesignTokens.figmaDeliverGreen;
  static const _inactive = DesignTokens.figmaNavInactive;

  @override
  Widget build(BuildContext context) {
    const topRadius = 24.0;
    const blur = 12.0;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                children: List.generate(items.length, (i) {
                  final it = items[i];
                  /// \`currentIndex == -1\` → no active tab (e.g. vendor Profile stack).
                  final selected = currentIndex >= 0 && i == currentIndex;
                  // Icon stays a steady color; selection reads from pill + label.
                  final labelFg = selected ? _active : _inactive;
                  final iconFg = _inactive;
                  final pillBg = selected
                      ? DesignTokens.figmaNavActiveMint
                      : Colors.transparent;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(i),
                      borderRadius: BorderRadius.circular(9999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Badge(
                              isLabelVisible: (it.badgeCount ?? 0) > 0,
                              label: Text(
                                '${it.badgeCount ?? 0}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: _active,
                              child: Icon(it.icon, size: 18, color: iconFg),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 15 / 10,
                                letterSpacing: 1,
                                color: labelFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BhoomiseBottomNavItem {
  const BhoomiseBottomNavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final String label;

  /// Total units in cart for this tab (e.g. bag tab). Omit when zero.
  final int? badgeCount;
}
