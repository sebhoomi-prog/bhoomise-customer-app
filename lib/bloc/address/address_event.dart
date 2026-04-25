import '../../modules/customer/address/domain/entities/delivery_address.dart';
import '../base/index.dart';

class AddressStarted extends BaseEvent {
  const AddressStarted();
}

class AddressSelected extends BaseEvent {
  const AddressSelected(this.address);

  final DeliveryAddress address;

  @override
  List<Object?> get props => <Object?>[address];
}

class AddressDeleteRequested extends BaseEvent {
  const AddressDeleteRequested(this.address);

  final DeliveryAddress address;

  @override
  List<Object?> get props => <Object?>[address];
}

class AddressSetDefaultRequested extends BaseEvent {
  const AddressSetDefaultRequested(this.address);

  final DeliveryAddress address;

  @override
  List<Object?> get props => <Object?>[address];
}

class AddressUserChanged extends BaseEvent {
  const AddressUserChanged(this.uid);

  final String? uid;

  @override
  List<Object?> get props => <Object?>[uid];
}

class AddressListUpdated extends BaseEvent {
  const AddressListUpdated(this.addresses);

  final List<DeliveryAddress> addresses;

  @override
  List<Object?> get props => <Object?>[addresses];
}
