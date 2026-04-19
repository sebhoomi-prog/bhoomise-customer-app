import '../entities/delivery_address.dart';
import '../repositories/address_repository.dart';

class WatchDeliveryAddresses {
  WatchDeliveryAddresses(this._repository);

  final AddressRepository _repository;

  Stream<List<DeliveryAddress>> call(String uid) =>
      _repository.watchAddresses(uid);
}
