import '../../modules/customer/address/domain/entities/delivery_address.dart';

class AddressBlocState {
  const AddressBlocState({
    this.loading = true,
    this.addresses = const <DeliveryAddress>[],
    this.selectedDeliveryId,
  });

  final bool loading;
  final List<DeliveryAddress> addresses;
  final String? selectedDeliveryId;

  AddressBlocState copyWith({
    bool? loading,
    List<DeliveryAddress>? addresses,
    String? selectedDeliveryId,
    bool clearSelected = false,
  }) {
    return AddressBlocState(
      loading: loading ?? this.loading,
      addresses: addresses ?? this.addresses,
      selectedDeliveryId: clearSelected
          ? null
          : (selectedDeliveryId ?? this.selectedDeliveryId),
    );
  }
}
