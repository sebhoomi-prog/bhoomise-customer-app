import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../bloc/auth/index.dart';
import '../../bloc/address/index.dart';
import '../../bloc/address_form/index.dart';
import '../../bloc/cart/index.dart';
import '../../bloc/home/index.dart';
import '../../bloc/profile/index.dart';
import '../../bloc/product/index.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/profile/presentation/pages/profile_form_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../modules/customer/address/presentation/pages/address_form_page.dart';
import '../../modules/customer/address/presentation/pages/address_list_page.dart';
import '../../modules/customer/cart/presentation/pages/available_coupons_page.dart';
import '../../modules/customer/navigation/presentation/pages/customer_shell_page.dart';
import '../../modules/customer/order/presentation/pages/order_track_page.dart';
import '../../modules/customer/product/presentation/pages/product_detail_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static Widget _withAuthBloc(Widget child) {
    final bloc = Get.find<AuthBloc>();
    return BlocProvider<AuthBloc>.value(
      value: bloc,
      child: BlocListener<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          final otpArgs = state.navigateToOtpArgs;
          if (otpArgs != null) {
            Get.offNamed(AppRoutes.otp, arguments: otpArgs);
            bloc.add(const AuthErrorAcknowledged());
            return;
          }
          final route = state.navigateToRoute;
          if (route != null && route.isNotEmpty) {
            Get.offAllNamed(route);
            bloc.add(const AuthErrorAcknowledged());
          }
        },
        child: child,
      ),
    );
  }

  static Widget _withCommerceBlocs(Widget child) {
    final cartBloc = Get.find<CartBloc>();
    final productBloc = Get.find<ProductBloc>();
    final homeBloc = Get.find<HomeBloc>();
    final profileBloc = Get.find<ProfileBloc>();
    return _CommerceRouteScope(
      productBloc: productBloc,
      cartBloc: cartBloc,
      homeBloc: homeBloc,
      profileBloc: profileBloc,
      child: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CartBloc>.value(value: cartBloc),
        BlocProvider<ProductBloc>.value(value: productBloc),
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
      ],
      child: child,
      ),
    );
  }

  static Widget _withCommerceBlocProviders(Widget child) {
    final cartBloc = Get.find<CartBloc>();
    final productBloc = Get.find<ProductBloc>();
    final homeBloc = Get.find<HomeBloc>();
    final profileBloc = Get.find<ProfileBloc>();
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CartBloc>.value(value: cartBloc),
        BlocProvider<ProductBloc>.value(value: productBloc),
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
      ],
      child: child,
    );
  }

  static Widget _withAddressBloc(Widget child) {
    final bloc = Get.find<AddressBloc>();
    return _AddressRouteScope(
      bloc: bloc,
      child: BlocProvider<AddressBloc>.value(value: bloc, child: child),
    );
  }

  static Widget _withProfileBloc(Widget child, {required bool isSignup}) {
    final bloc = Get.find<ProfileBloc>();
    return _ProfileRouteScope(
      bloc: bloc,
      isSignup: isSignup,
      child: BlocProvider<ProfileBloc>.value(value: bloc, child: child),
    );
  }

  static Widget _withAddressFormBloc(Widget child) {
    final bloc = Get.find<AddressFormBloc>();
    return _AddressFormRouteScope(
      bloc: bloc,
      child: BlocProvider<AddressFormBloc>.value(value: bloc, child: child),
    );
  }

  static final routes = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.login,
      page: () => _withAuthBloc(const PhoneLoginPage()),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => _withAuthBloc(const OtpVerificationPage()),
    ),
    GetPage(
      name: AppRoutes.signupProfile,
      page: () => _withProfileBloc(const ProfileFormPage(), isSignup: true),
    ),
    GetPage(
      name: AppRoutes.profileEdit,
      page: () => _withProfileBloc(const ProfileFormPage(), isSignup: false),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => _withCommerceBlocs(const CustomerShellPage()),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => _withCommerceBlocProviders(const ProductDetailPage()),
    ),
    GetPage(name: AppRoutes.orderTrack, page: () => const OrderTrackPage()),
    GetPage(
      name: AppRoutes.availableCoupons,
      page: () => const AvailableCouponsPage(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => _withAddressBloc(const AddressListPage()),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: () => _withAddressFormBloc(const AddressFormPage()),
    ),
  ];
}

class _CommerceRouteScope extends StatefulWidget {
  const _CommerceRouteScope({
    required this.productBloc,
    required this.cartBloc,
    required this.homeBloc,
    required this.profileBloc,
    required this.child,
  });

  final ProductBloc productBloc;
  final CartBloc cartBloc;
  final HomeBloc homeBloc;
  final ProfileBloc profileBloc;
  final Widget child;

  @override
  State<_CommerceRouteScope> createState() => _CommerceRouteScopeState();
}

class _CommerceRouteScopeState extends State<_CommerceRouteScope> {
  @override
  void initState() {
    super.initState();
    widget.productBloc.add(const ProductLoadRequested());
    widget.cartBloc.add(const CartLoadRequested());
    widget.homeBloc.add(const HomeStarted());
    widget.profileBloc.add(const ProfileStarted(isSignup: false));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ProfileRouteScope extends StatefulWidget {
  const _ProfileRouteScope({
    required this.bloc,
    required this.isSignup,
    required this.child,
  });

  final ProfileBloc bloc;
  final bool isSignup;
  final Widget child;

  @override
  State<_ProfileRouteScope> createState() => _ProfileRouteScopeState();
}

class _ProfileRouteScopeState extends State<_ProfileRouteScope> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(ProfileStarted(isSignup: widget.isSignup));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _AddressRouteScope extends StatefulWidget {
  const _AddressRouteScope({required this.bloc, required this.child});

  final AddressBloc bloc;
  final Widget child;

  @override
  State<_AddressRouteScope> createState() => _AddressRouteScopeState();
}

class _AddressRouteScopeState extends State<_AddressRouteScope> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(const AddressStarted());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _AddressFormRouteScope extends StatefulWidget {
  const _AddressFormRouteScope({required this.bloc, required this.child});

  final AddressFormBloc bloc;
  final Widget child;

  @override
  State<_AddressFormRouteScope> createState() => _AddressFormRouteScopeState();
}

class _AddressFormRouteScopeState extends State<_AddressFormRouteScope> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(const AddressFormStarted());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
