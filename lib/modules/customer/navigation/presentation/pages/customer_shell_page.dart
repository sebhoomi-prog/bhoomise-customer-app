import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'dart:async';

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
  StreamSubscription<bool>? _connectivitySub;
  bool _lastOnline = true;

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
    final connectivity = Get.find<ConnectivitySyncService>();
    _lastOnline = connectivity.isOnline.value;
    _connectivitySub = connectivity.isOnline.stream.listen(_onConnectivityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabFromRouteArguments());
  }

  void _onConnectivityChanged(bool online) {
    if (!mounted || online == _lastOnline) return;
    _lastOnline = online;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          online ? 'Back online. Sync resumed.' : 'You are offline. Using local data.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: online ? const Color(0xFF166534) : const Color(0xFF9A3412),
        duration: Duration(seconds: online ? 2 : 3),
      ),
    );
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
          StreamBuilder<bool>(
            stream: Get.find<ConnectivitySyncService>().isOnline.stream,
            initialData: Get.find<ConnectivitySyncService>().isOnline.value,
            builder: (context, snapshot) {
            final online = snapshot.data ?? true;
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
            child: StreamBuilder<int>(
              stream: shell.tabIndex.stream,
              initialData: shell.tabIndex.value,
              builder: (context, snapshot) => IndexedStack(
                index: snapshot.data ?? 0,
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
          return StreamBuilder<int>(
            stream: shell.tabIndex.stream,
            initialData: shell.tabIndex.value,
            builder: (context, snapshot) {
            return BhoomiseRoleBottomNav(
              currentIndex: snapshot.data ?? 0,
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
      floatingActionButton: BlocSelector<CartBloc, CartBlocState, int>(
        selector: (state) => state.totalItemQuantity,
        builder: (context, units) {
          return StreamBuilder<int>(
            stream: shell.tabIndex.stream,
            initialData: shell.tabIndex.value,
            builder: (context, snapshot) {
            // Show floating cart only on Home tab.
            if ((snapshot.data ?? 0) != 0) return const SizedBox.shrink();
            return FloatingActionButton(
              heroTag: 'customer_shell_cart_fab',
              onPressed: () {
                shell.setTab(2);
                context.read<CartBloc>().add(const CartLoadRequested());
              },
              backgroundColor: const Color(0xFF00873A),
              foregroundColor: Colors.white,
              elevation: 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_checkout_rounded),
                  if (units > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          units > 99 ? '99+' : '$units',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
