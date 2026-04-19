import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/customer/address/data/datasources/address_local_datasource.dart';
import '../../modules/customer/address/data/datasources/address_remote_datasource.dart';
import '../../modules/customer/address/data/repositories/address_repository_impl.dart';
import '../../modules/customer/address/domain/repositories/address_repository.dart';
import '../../modules/customer/address/domain/usecases/create_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/delete_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/set_default_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/update_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/watch_delivery_addresses.dart';

class AddressDependencies {
  static void register() {
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
}
