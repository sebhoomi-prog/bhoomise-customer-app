import '../../domain/entities/delivery_address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import '../models/delivery_address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remote);

  final AddressRemoteDataSource _remote;

  @override
  Stream<List<DeliveryAddress>> watchAddresses(String uid) =>
      _remote.watchAddresses(uid).map(_toEntityList);

  static List<DeliveryAddress> _toEntityList(List<DeliveryAddressModel> list) {
    return list
        .map(
          (m) => DeliveryAddress(
            id: m.id,
            label: m.label,
            recipientName: m.recipientName,
            phone: m.phone,
            line1: m.line1,
            line2: m.line2,
            landmark: m.landmark,
            city: m.city,
            state: m.state,
            pincode: m.pincode,
            isDefault: m.isDefault,
          ),
        )
        .toList();
  }

  @override
  Future<String> createAddress(String uid, DeliveryAddress address) {
    final model = DeliveryAddressModel(
      id: address.id,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      isDefault: address.isDefault,
    );
    return _remote.createAddress(uid, model);
  }

  @override
  Future<void> updateAddress(String uid, DeliveryAddress address) {
    final model = DeliveryAddressModel(
      id: address.id,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      isDefault: address.isDefault,
    );
    return _remote.updateAddress(uid, model);
  }

  @override
  Future<void> deleteAddress(String uid, String addressId) =>
      _remote.deleteAddress(uid, addressId);

  @override
  Future<void> setDefaultAddress(String uid, String addressId) =>
      _remote.setDefaultAddress(uid, addressId);
}
