import '../../modules/customer/address/domain/entities/delivery_address.dart';
import '../base/index.dart';

class AddressFormStarted extends BaseEvent {
  const AddressFormStarted();
}

class AddressFormAuthChanged extends BaseEvent {
  const AddressFormAuthChanged({required this.uid, required this.phoneNumber});

  final String? uid;
  final String? phoneNumber;

  @override
  List<Object?> get props => <Object?>[uid, phoneNumber];
}

class AddressFormSaveRequested extends BaseEvent {
  const AddressFormSaveRequested({required this.address, required this.isEdit});

  final DeliveryAddress address;
  final bool isEdit;

  @override
  List<Object?> get props => <Object?>[address, isEdit];
}

class AddressFormUiFlagsCleared extends BaseEvent {
  const AddressFormUiFlagsCleared();
}
