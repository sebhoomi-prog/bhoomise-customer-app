import '../entities/delivery_address.dart';
import '../repositories/address_repository.dart';

class CreateDeliveryAddress {
  CreateDeliveryAddress(this._repository);

  final AddressRepository _repository;

  Future<String> call(String uid, DeliveryAddress address) =>
      _repository.createAddress(uid, address);
}
