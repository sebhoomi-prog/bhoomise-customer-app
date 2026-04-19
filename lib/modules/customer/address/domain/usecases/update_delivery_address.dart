import '../entities/delivery_address.dart';
import '../repositories/address_repository.dart';

class UpdateDeliveryAddress {
  UpdateDeliveryAddress(this._repository);

  final AddressRepository _repository;

  Future<void> call(String uid, DeliveryAddress address) =>
      _repository.updateAddress(uid, address);
}
