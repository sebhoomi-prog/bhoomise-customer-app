import 'package:get/get.dart';

import '../../config/backend_config.dart';
import '../../core/network/mock_asset_client.dart';
import '../../core/storage/local_storage.dart';
import '../../modules/customer/cart/data/repositories/cart_repository_impl.dart';
import '../../modules/customer/cart/domain/repositories/cart_repository.dart';
import '../../modules/customer/cart/domain/usecases/add_to_cart.dart';
import '../../modules/customer/cart/domain/usecases/change_cart_quantity.dart';
import '../../modules/customer/cart/domain/usecases/remove_from_cart.dart';
import '../../modules/customer/cart/data/coupon_catalog_service.dart';
import '../../modules/customer/cart/presentation/controllers/cart_controller.dart';
import '../../modules/customer/product/data/datasources/product_asset_datasource.dart';
import '../../modules/customer/product/data/datasources/product_firestore_datasource.dart';
import '../../modules/customer/product/data/datasources/product_mock_datasource.dart';
import '../../modules/customer/product/data/datasources/product_remote_datasource.dart';
import '../../modules/customer/product/data/repositories/product_repository_impl.dart';
import '../../modules/customer/product/domain/repositories/product_repository.dart';
import '../../modules/customer/product/domain/usecases/get_products.dart';
import '../../modules/customer/product/presentation/controllers/product_list_controller.dart';
import '../../modules/customer/home/data/customer_home_firestore_datasource.dart';
import '../../shared/firebase/repositories/shared_app_firestore_repository.dart';
import '../../shared/firebase/repositories/shared_catalog_firestore_repository.dart';
import '../../shared/firebase/repositories/shared_coupon_firestore_repository.dart';

/// Product catalog + cart (inventory / orders get their own bindings later).
class CommerceDependencies {
  static void register() {
    Get.lazyPut<CustomerHomeFirestoreDataSource>(
      () => CustomerHomeFirestoreDataSource(appRepo: Get.find<SharedAppFirestoreRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProductRemoteDataSource>(
      () {
        if (BackendConfig.useFirestoreCatalog) {
          return ProductFirestoreDataSource(
            catalog: Get.find<SharedCatalogFirestoreRepository>(),
          );
        }
        if (BackendConfig.useMockApiAssets) {
          return ProductAssetDataSource(Get.find<MockAssetClient>());
        }
        return ProductMockDataSource();
      },
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetProducts>(
      () => GetProducts(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ProductListController>(
      () => ProductListController(Get.find()),
      fenix: true,
    );

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
    Get.lazyPut<CartController>(
      () => CartController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut<CouponCatalogService>(
      () => CouponCatalogService(
        coupons: Get.find<SharedCouponFirestoreRepository>(),
      ),
      fenix: true,
    );
  }
}
