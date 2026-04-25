import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../modules/customer/address/domain/usecases/create_delivery_address.dart';
import '../../modules/customer/address/domain/usecases/update_delivery_address.dart';
import '../base/index.dart';
import 'address_form_event.dart';
import 'address_form_state.dart';

class AddressFormBloc extends Bloc<BaseEvent, AddressFormBlocState> {
  AddressFormBloc(
    this._watchAuthState,
    this._createDeliveryAddress,
    this._updateDeliveryAddress,
  ) : super(const AddressFormBlocState()) {
    on<AddressFormStarted>(_onStarted);
    on<AddressFormAuthChanged>(_onAuthChanged);
    on<AddressFormSaveRequested>(_onSaveRequested);
    on<AddressFormUiFlagsCleared>(_onUiFlagsCleared);
  }

  final WatchAuthState _watchAuthState;
  final CreateDeliveryAddress _createDeliveryAddress;
  final UpdateDeliveryAddress _updateDeliveryAddress;

  StreamSubscription<dynamic>? _authSub;

  Future<void> _onStarted(
    AddressFormStarted event,
    Emitter<AddressFormBlocState> emit,
  ) async {
    await _authSub?.cancel();
    _authSub = _watchAuthState().listen((user) {
      add(
        AddressFormAuthChanged(uid: user?.uid, phoneNumber: user?.phoneNumber),
      );
    });
  }

  Future<void> _onAuthChanged(
    AddressFormAuthChanged event,
    Emitter<AddressFormBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        uid: event.uid,
        phoneNumber: event.phoneNumber,
        requireSignIn: false,
      ),
    );
  }

  Future<void> _onSaveRequested(
    AddressFormSaveRequested event,
    Emitter<AddressFormBlocState> emit,
  ) async {
    final uid = state.uid;
    if (uid == null) {
      emit(state.copyWith(requireSignIn: true));
      return;
    }
    emit(
      state.copyWith(
        saving: true,
        requireSignIn: false,
        saveSuccess: false,
        clearError: true,
      ),
    );
    try {
      if (event.isEdit) {
        await _updateDeliveryAddress(uid, event.address);
      } else {
        await _createDeliveryAddress(uid, event.address);
      }
      emit(state.copyWith(saving: false, saveSuccess: true));
    } on Object catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: AppStrings.addressSaveFailed,
        ),
      );
    }
  }

  Future<void> _onUiFlagsCleared(
    AddressFormUiFlagsCleared event,
    Emitter<AddressFormBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        requireSignIn: false,
        saveSuccess: false,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
