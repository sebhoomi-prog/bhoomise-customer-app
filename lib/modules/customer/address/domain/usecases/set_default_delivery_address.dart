import '../repositories/address_repository.dart';

class SetDefaultDeliveryAddress {
  SetDefaultDeliveryAddress(this._repository);

  final AddressRepository _repository;

  Future<void> call(String uid, String addressId) =>
      _repository.setDefaultAddress(uid, addressId);
}
