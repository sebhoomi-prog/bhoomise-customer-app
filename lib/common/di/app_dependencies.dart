import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' show Interceptor;

import '../../bloc/address/address_bloc.dart';
import '../../bloc/address_form/address_form_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_interceptors.dart';
import '../../core/api/dio_factory.dart';
import '../../core/location/delivery_location_controller.dart';
import '../../core/network/connectivity_sync_service.dart';
import '../../core/network/mock_asset_client.dart';
import '../../core/session/app_session_service.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_api_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_phone_verification.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/verify_sms_code.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/profile/data/datasources/profile_asset_datasource.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/resolve_post_auth_destination.dart';
import '../../features/profile/domain/usecases/save_user_profile.dart';
import '../../modules/customer/address/data/datasources/address_local_datasource.dart';
import '../../modules/customer/address/data/datasources/address_remote_datasource.dart';
import '../../modules/customer/address/data/repositories/address_repository_impl.dart';
import '../../modules/customer/address/domain/repositories/address_repository.dart';
import '../../modules/customer/address/domain/usecases/create_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/delete_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/set_default_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/update_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/watch_delivery_addresses.dart';
import '../../modules/customer/cart/data/coupon_catalog_service.dart';
import '../../modules/customer/cart/data/repositories/cart_repository_impl.dart';
import '../../modules/customer/cart/domain/repositories/cart_repository.dart';
import '../../modules/customer/cart/domain/usecases/add_to_cart.dart';
import '../../modules/customer/cart/domain/usecases/change_cart_quantity.dart';
import '../../modules/customer/cart/domain/usecases/remove_from_cart.dart';
import '../../modules/customer/home/data/customer_home_api_datasource.dart';
import '../../modules/customer/navigation/presentation/controllers/customer_shell_controller.dart';
import '../../modules/customer/order/data/datasources/order_api_datasource.dart';
import '../../modules/customer/product/data/datasources/product_api_datasource.dart';
import '../../modules/customer/product/data/datasources/product_asset_datasource.dart';
import '../../modules/customer/product/data/datasources/product_mock_datasource.dart';
import '../../modules/customer/product/data/datasources/product_remote_datasource.dart';
import '../../modules/customer/product/data/repositories/product_repository_impl.dart';
import '../../modules/customer/product/domain/repositories/product_repository.dart';
import '../../modules/customer/product/domain/usecases/get_products.dart';

Future<void> registerAppDependencies() async {
  _registerCoreDependencies();
  _registerProfileDependencies();
  _registerAuthDependencies();
  _registerAddressDependencies();
  _registerCommerceDependencies();
  _registerRouteLevelDependencies();
}

void _registerCoreDependencies() {
  Get.put<AppSessionService>(
    AppSessionService(Get.find<SharedPreferences>()),
    permanent: true,
  );
  Get.put<ConnectivitySyncService>(
    ConnectivitySyncService(Get.find<LocalStorage>()),
    permanent: true,
  );
  Get.put<DeliveryLocationController>(
    DeliveryLocationController(Get.find<SharedPreferences>()),
    permanent: true,
  );
  Get.lazyPut<ApiClient>(
    () => ApiClient(
      dio: DioFactory.create(
        baseUrl: BackendConfig.apiBaseUrl.trim(),
        extraInterceptors: <Interceptor>[
          AuthBearerInterceptor(() => Get.find<AppSessionService>().apiToken),
          ApiLoggerInterceptor(),
        ],
      ),
    ),
    fenix: true,
  );
  if (BackendConfig.useMockApiAssets) {
    Get.put<MockAssetClient>(MockAssetClient(), permanent: true);
  }
}

void _registerProfileDependencies() {
  Get.lazyPut<ProfileRemoteDataSource>(() {
    if (BackendConfig.useMockApiAssets) {
      return ProfileAssetDataSource(
        Get.find<SharedPreferences>(),
        Get.find<MockAssetClient>(),
      );
    }
    return ProfileLocalDataSource(Get.find<SharedPreferences>());
  }, fenix: true);
  Get.lazyPut<ProfileRepository>(
    () => ProfileRepositoryImpl(Get.find()),
    fenix: true,
  );
  Get.lazyPut<GetUserProfile>(() => GetUserProfile(Get.find()), fenix: true);
  Get.lazyPut<SaveUserProfile>(() => SaveUserProfile(Get.find()), fenix: true);
  Get.lazyPut<ResolvePostAuthDestination>(
    () => ResolvePostAuthDestination(Get.find()),
    fenix: true,
  );
}

void _registerAuthDependencies() {
  Get.lazyPut<AuthRemoteDataSource>(
    () => AuthApiDataSource(
      Get.find<ApiClient>(),
      Get.find<AppSessionService>(),
      Get.find<SharedPreferences>(),
    ),
    fenix: true,
  );
  Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(Get.find()),
    fenix: true,
  );
  Get.lazyPut<WatchAuthState>(() => WatchAuthState(Get.find()), fenix: true);
  Get.lazyPut<SendPhoneVerification>(
    () => SendPhoneVerification(Get.find()),
    fenix: true,
  );
  Get.lazyPut<VerifySmsCode>(() => VerifySmsCode(Get.find()), fenix: true);
  Get.lazyPut<SignOut>(() => SignOut(Get.find()), fenix: true);
  Get.put<AuthController>(
    AuthController(Get.find(), Get.find(), Get.find(), Get.find(), Get.find()),
    permanent: true,
  );
  Get.lazyPut<AuthBloc>(
    () => AuthBloc(
      watchAuthState: Get.find<WatchAuthState>(),
      sendPhoneVerification: Get.find<SendPhoneVerification>(),
      verifySmsCode: Get.find<VerifySmsCode>(),
      resolvePostAuthDestination: Get.find(),
      prefs: Get.find<SharedPreferences>(),
      authRepository: Get.find<AuthRepository>(),
    ),
    fenix: true,
  );
}

void _registerAddressDependencies() {
  Get.lazyPut<AddressRemoteDataSource>(
    () => AddressLocalDataSource(Get.find<SharedPreferences>()),
    fenix: true,
  );
  Get.lazyPut<AddressRepository>(
    () => AddressRepositoryImpl(Get.find()),
    fenix: true,
  );
  Get.lazyPut<WatchDeliveryAddresses>(
    () => WatchDeliveryAddresses(Get.find()),
    fenix: true,
  );
  Get.lazyPut<CreateDeliveryAddress>(
    () => CreateDeliveryAddress(Get.find()),
    fenix: true,
  );
  Get.lazyPut<UpdateDeliveryAddress>(
    () => UpdateDeliveryAddress(Get.find()),
    fenix: true,
  );
  Get.lazyPut<DeleteDeliveryAddress>(
    () => DeleteDeliveryAddress(Get.find()),
    fenix: true,
  );
  Get.lazyPut<SetDefaultDeliveryAddress>(
    () => SetDefaultDeliveryAddress(Get.find()),
    fenix: true,
  );
}

void _registerCommerceDependencies() {
  Get.lazyPut<CustomerHomeApiDataSource>(
    () => CustomerHomeApiDataSource(Get.find<ApiClient>()),
    fenix: true,
  );
  Get.lazyPut<ProductRemoteDataSource>(() {
    if (BackendConfig.hasRestApi) {
      return ProductApiDataSource(Get.find<ApiClient>());
    }
    if (BackendConfig.useMockApiAssets) {
      return ProductAssetDataSource(Get.find<MockAssetClient>());
    }
    return ProductMockDataSource();
  }, fenix: true);
  Get.lazyPut<ProductRepository>(
    () => ProductRepositoryImpl(Get.find()),
    fenix: true,
  );
  Get.lazyPut<GetProducts>(() => GetProducts(Get.find()), fenix: true);
  Get.lazyPut<CartRepository>(
    () => CartRepositoryImpl(Get.find<LocalStorage>()),
    fenix: true,
  );
  Get.lazyPut<AddToCart>(() => AddToCart(Get.find()), fenix: true);
  Get.lazyPut<RemoveFromCart>(() => RemoveFromCart(Get.find()), fenix: true);
  Get.lazyPut<ChangeCartQuantity>(
    () => ChangeCartQuantity(Get.find()),
    fenix: true,
  );
  Get.lazyPut<ProductBloc>(() => ProductBloc(Get.find()), fenix: true);
  Get.lazyPut<CartBloc>(
    () => CartBloc(Get.find(), Get.find(), Get.find(), Get.find()),
    fenix: true,
  );
  Get.lazyPut<CouponCatalogService>(
    () => CouponCatalogService(Get.find<ApiClient>()),
    fenix: true,
  );
  Get.lazyPut<OrderApiDataSource>(
    () => OrderApiDataSource(Get.find<ApiClient>()),
    fenix: true,
  );
}

void _registerRouteLevelDependencies() {
  Get.put<CustomerShellController>(CustomerShellController(), permanent: true);
  Get.lazyPut<HomeBloc>(
    () => HomeBloc(Get.find(), Get.find(), Get.find()),
    fenix: true,
  );
  Get.lazyPut<ProfileBloc>(
    () => ProfileBloc(Get.find(), Get.find(), Get.find(), Get.find()),
    fenix: true,
  );
  Get.lazyPut<AddressBloc>(
    () => AddressBloc(Get.find(), Get.find(), Get.find(), Get.find()),
    fenix: true,
  );
  Get.lazyPut<AddressFormBloc>(
    () => AddressFormBloc(Get.find(), Get.find(), Get.find()),
    fenix: true,
  );
}
