import '../models/delivery_address_model.dart';

abstract class AddressRemoteDataSource {
  Stream<List<DeliveryAddressModel>> watchAddresses(String uid);

  Future<String> createAddress(String uid, DeliveryAddressModel address);

  Future<void> updateAddress(String uid, DeliveryAddressModel address);

  Future<void> deleteAddress(String uid, String addressId);

  Future<void> setDefaultAddress(String uid, String addressId);
}
