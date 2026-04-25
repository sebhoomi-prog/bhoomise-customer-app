import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../modules/customer/address/domain/entities/delivery_address.dart';
import '../../modules/customer/address/domain/usecases/delete_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/set_default_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/watch_delivery_addresses.dart';
import '../base/index.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<BaseEvent, AddressBlocState> {
  AddressBloc(
    this._watchAuthState,
    this._watchAddresses,
    this._deleteAddress,
    this._setDefault,
  ) : super(const AddressBlocState()) {
    on<AddressStarted>(_onStarted);
    on<AddressSelected>(_onSelected);
    on<AddressDeleteRequested>(_onDeleteRequested);
    on<AddressSetDefaultRequested>(_onSetDefaultRequested);
    on<AddressUserChanged>(_onUserChanged);
    on<AddressListUpdated>(_onListUpdated);
  }

  final WatchAuthState _watchAuthState;
  final WatchDeliveryAddresses _watchAddresses;
  final DeleteDeliveryAddress _deleteAddress;
  final SetDefaultDeliveryAddress _setDefault;

  StreamSubscription<dynamic>? _authSub;
  StreamSubscription<dynamic>? _addressSub;
  String? _activeUid;

  Future<void> _onStarted(
    AddressStarted event,
    Emitter<AddressBlocState> emit,
  ) async {
    await _authSub?.cancel();
    _authSub = _watchAuthState().listen((user) {
      add(AddressUserChanged(user?.uid));
    });
  }

  Future<void> _onUserChanged(
    AddressUserChanged event,
    Emitter<AddressBlocState> emit,
  ) async {
    await _addressSub?.cancel();
    if (event.uid == null) {
      _activeUid = null;
      emit(
        state.copyWith(
          loading: false,
          addresses: const <DeliveryAddress>[],
          clearSelected: true,
        ),
      );
      return;
    }
    _activeUid = event.uid;
    emit(state.copyWith(loading: true));
    _addressSub = _watchAddresses(event.uid!).listen((list) {
      add(AddressListUpdated(list));
    });
  }

  String? _resolveSelected(List<DeliveryAddress> list) {
    if (list.isEmpty) {
      return null;
    }
    final current = state.selectedDeliveryId;
    if (current != null && list.any((a) => a.id == current)) {
      return current;
    }
    return list.firstWhere((a) => a.isDefault, orElse: () => list.first).id;
  }

  Future<void> _onListUpdated(
    AddressListUpdated event,
    Emitter<AddressBlocState> emit,
  ) async {
    final selected = _resolveSelected(event.addresses);
    emit(
      state.copyWith(
        loading: false,
        addresses: event.addresses,
        selectedDeliveryId: selected,
        clearSelected: selected == null,
      ),
    );
  }

  Future<void> _onSelected(
    AddressSelected event,
    Emitter<AddressBlocState> emit,
  ) async {
    emit(state.copyWith(selectedDeliveryId: event.address.id));
  }

  Future<void> _onDeleteRequested(
    AddressDeleteRequested event,
    Emitter<AddressBlocState> emit,
  ) async {
    final uid = _activeUid;
    if (uid == null) {
      return;
    }
    await _deleteAddress(uid, event.address.id);
  }

  Future<void> _onSetDefaultRequested(
    AddressSetDefaultRequested event,
    Emitter<AddressBlocState> emit,
  ) async {
    final uid = _activeUid;
    if (uid == null) {
      return;
    }
    await _setDefault(uid, event.address.id);
  }

  @override
  Future<void> close() async {
    await _addressSub?.cancel();
    await _authSub?.cancel();
    return super.close();
  }
}
