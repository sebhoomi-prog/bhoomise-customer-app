import '../repositories/address_repository.dart';

class DeleteDeliveryAddress {
  DeleteDeliveryAddress(this._repository);

  final AddressRepository _repository;

  Future<void> call(String uid, String addressId) =>
      _repository.deleteAddress(uid, addressId);
}
