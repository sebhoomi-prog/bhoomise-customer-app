import '../entities/delivery_address.dart';

abstract class AddressRepository {
  Stream<List<DeliveryAddress>> watchAddresses(String uid);

  Future<String> createAddress(String uid, DeliveryAddress address);

  Future<void> updateAddress(String uid, DeliveryAddress address);

  Future<void> deleteAddress(String uid, String addressId);

  Future<void> setDefaultAddress(String uid, String addressId);
}
