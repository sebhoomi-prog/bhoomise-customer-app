import 'package:get/get.dart';

import '../../apps/customer/pages/address_form_page.dart';
import '../../apps/customer/pages/address_list_page.dart';
import '../../apps/customer/pages/available_coupons_page.dart';
import '../../apps/customer/pages/customer_shell_page.dart';
import '../../apps/customer/pages/order_track_page.dart';
import '../../apps/customer/pages/product_detail_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/profile/presentation/controllers/profile_form_controller.dart';
import '../../features/profile/presentation/pages/profile_form_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../modules/customer/home/presentation/controllers/home_controller.dart';
import '../../modules/customer/address/presentation/controllers/address_list_controller.dart';
import '../../modules/customer/navigation/presentation/controllers/customer_shell_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const PhoneLoginPage(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpVerificationPage(),
    ),
    GetPage(
      name: AppRoutes.signupProfile,
      page: () => const ProfileFormPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileFormController(Get.find()), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.profileEdit,
      page: () => const ProfileFormPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileFormController(Get.find()), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const CustomerShellPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CustomerShellController>()) {
          Get.put(CustomerShellController(), permanent: true);
        }
        Get.lazyPut(
          () => HomeController(Get.find(), Get.find()),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
    ),
    GetPage(
      name: AppRoutes.orderTrack,
      page: () => const OrderTrackPage(),
    ),
    GetPage(
      name: AppRoutes.availableCoupons,
      page: () => const AvailableCouponsPage(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => AddressListController(
            Get.find(),
            Get.find(),
            Get.find(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: () => const AddressFormPage(),
    ),
  ];
}
