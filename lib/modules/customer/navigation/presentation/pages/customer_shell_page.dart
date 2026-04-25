import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../bloc/cart/index.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/network/connectivity_sync_service.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/bhoomise_role_bottom_nav.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../home/presentation/home_page.dart';
import '../../../product/presentation/pages/product_catalog_page.dart';
import '../controllers/customer_shell_controller.dart';
import 'customer_profile_tab_page.dart';

/// Customer shell — Figma: Home · Search · Orders · Profile.
///
/// Tab index lives in [CustomerShellController] so opening Search/Cart from any
/// button keeps the bottom bar aligned with the visible tab.
class CustomerShellPage extends StatefulWidget {
  const CustomerShellPage({super.key});

  @override
  State<CustomerShellPage> createState() => _CustomerShellPageState();
}

class _CustomerShellPageState extends State<CustomerShellPage> {
  List<BhoomiseBottomNavItem> _navItems(int cartUnits) {
    final bagBadge = cartUnits > 0 ? cartUnits : null;
    return [
      const BhoomiseBottomNavItem(
        icon: Icons.home_rounded,
        label: AppStrings.navHome,
      ),
      const BhoomiseBottomNavItem(
        icon: Icons.search_rounded,
        label: AppStrings.navSearch,
      ),
      BhoomiseBottomNavItem(
        icon: Icons.shopping_bag_outlined,
        label: AppStrings.navOrders,
        badgeCount: bagBadge,
      ),
      const BhoomiseBottomNavItem(
        icon: Icons.person_rounded,
        label: AppStrings.navProfile,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabFromRouteArguments());
  }

  void _syncTabFromRouteArguments() {
    if (!Get.isRegistered<CustomerShellController>()) return;
    final shell = Get.find<CustomerShellController>();
    final args = Get.arguments;
    if (args is int) {
      shell.setTab(args);
      return;
    }
    if (args is Map && args['tab'] is int) {
      shell.setTab(args['tab'] as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<CustomerShellController>();

    return Scaffold(
      body: Column(
        children: [
          Obx(() {
            final online = Get.find<ConnectivitySyncService>().isOnline.value;
            if (online) return const SizedBox.shrink();
            return Material(
              color: DesignTokens.figmaHeaderFrostTint,
              child: SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceLg,
                    vertical: DesignTokens.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Expanded(
                        child: Text(
                          AppStrings.offlineTryAgain,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: shell.tabIndex.value,
                children: const [
                  HomePage(),
                  ProductCatalogPage(),
                  CartPage(),
                  CustomerProfileTabPage(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocSelector<CartBloc, CartBlocState, int>(
        selector: (state) => state.totalItemQuantity,
        builder: (context, units) {
          return Obx(() {
            return BhoomiseRoleBottomNav(
              currentIndex: shell.tabIndex.value,
              onTap: (i) {
                shell.setTab(i);
                if (i == 2) {
                  context.read<CartBloc>().add(const CartLoadRequested());
                }
              },
              items: _navItems(units),
            );
          });
        },
      ),
    );
  }
}
