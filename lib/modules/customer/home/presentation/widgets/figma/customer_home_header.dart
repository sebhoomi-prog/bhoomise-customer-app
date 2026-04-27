import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/location/delivery_location_controller.dart';
import '../../../../../../core/theme/design_tokens.dart';
import '../../../../../../core/theme/figma_typography.dart';
import '../../../../../../bloc/home/index.dart';

/// Top row: deliver-to (live GPS area), brand title, profile — quick-commerce style.
class CustomerHomeFigmaHeader extends StatelessWidget {
  const CustomerHomeFigmaHeader({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

  static const _green = DesignTokens.figmaDeliverGreen;

  Future<void> _openAddressFormWithPrefill() async {
    final loc = Get.find<DeliveryLocationController>();
    final pre = await loc.fetchPrefillMap();
    await Get.toNamed<void>(AppRoutes.addressForm, arguments: pre);
  }

  @override
  Widget build(BuildContext context) {
    final loc = Get.find<DeliveryLocationController>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openAddressFormWithPrefill,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: DesignTokens.figmaCategoryCard,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: StreamBuilder<bool>(
                        stream: loc.isLocating.stream,
                        initialData: loc.isLocating.value,
                        builder: (context, snapshot) {
                        final loading = snapshot.data ?? false;
                        return loading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: DesignTokens.figmaPinIconGreen,
                                ),
                              )
                            : Icon(
                                Icons.location_on_rounded,
                                color: DesignTokens.figmaPinIconGreen,
                                size: 20,
                              );
                      }),
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.deliverToLabel,
                            style: FigmaTypography.customerDeliverLabel(),
                          ),
                          StreamBuilder<String>(
                            stream: loc.primaryLine.stream,
                            initialData: loc.primaryLine.value,
                            builder: (context, pSnapshot) {
                            final p = pSnapshot.data ?? '';
                            return StreamBuilder<String>(
                              stream: loc.secondaryLine.stream,
                              initialData: loc.secondaryLine.value,
                              builder: (context, sSnapshot) {
                            final s = sSnapshot.data ?? '';
                            final title = p.isEmpty
                                ? AppStrings.deliverToFallbackArea
                                : p;
                            final sub = s.isEmpty
                                ? AppStrings.deliverToFallbackCity
                                : s;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FigmaTypography.customerDeliverCity(
                                    _green,
                                  ),
                                ),
                                Text(
                                  sub,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: DesignTokens.figmaSectionInk
                                            .withValues(alpha: 0.75),
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            );
                          });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: DesignTokens.figmaAccentLime,
                  width: 2,
                ),
              ),
              child: BlocBuilder<HomeBloc, HomeBlocState>(
                builder: (context, state) {
                  final name = state.profile?.displayName;
                  final initial = (name != null && name.isNotEmpty)
                      ? name.trim().substring(0, 1).toUpperCase()
                      : '?';
                  return CircleAvatar(
                    radius: 16.055,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
