import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../navigation/customer_shell_navigation.dart';
import '../../../../../../core/theme/design_tokens.dart';

/// Search field pill — Figma Customer Home (`9:3`): `#D9E3F6`, 16px/24 padding.
class CustomerSearchPill extends StatelessWidget {
  const CustomerSearchPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignTokens.figmaSearchBarFill,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: DesignTokens.figmaSearchGlyph,
                size: 18,
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Text(
                  AppStrings.homeSearchHint,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 19 / 16,
                    color: DesignTokens.figmaSearchGlyph,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static VoidCallback openCatalog() => () {
        CustomerShellNavigation.goSearch();
      };
}
