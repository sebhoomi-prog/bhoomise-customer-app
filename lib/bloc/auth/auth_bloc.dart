import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes/app_routes.dart';
import '../../core/session/phone_otp_route_persistence.dart';
import '../../features/profile/domain/usecases/resolve_post_auth_destination.dart';
import '../../features/auth/domain/usecases/send_phone_verification.dart';
import '../../features/auth/domain/usecases/verify_sms_code.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../base/index.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<BaseEvent, AuthBlocState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required SendPhoneVerification sendPhoneVerification,
    required VerifySmsCode verifySmsCode,
    required ResolvePostAuthDestination resolvePostAuthDestination,
    required SharedPreferences prefs,
    required AuthRepository authRepository,
  })  : _watchAuthState = watchAuthState,
        _sendPhoneVerification = sendPhoneVerification,
        _verifySmsCode = verifySmsCode,
        _resolvePostAuthDestination = resolvePostAuthDestination,
        _prefs = prefs,
        _authRepository = authRepository,
        super(const AuthBlocState()) {
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthResendOtpRequested>(_onResendOtp);
    on<AuthOtpFlowCancelled>(_onOtpFlowCancelled);
    on<AuthErrorAcknowledged>(_onErrorAck);
  }

  final WatchAuthState _watchAuthState;
  final SendPhoneVerification _sendPhoneVerification;
  final VerifySmsCode _verifySmsCode;
  final ResolvePostAuthDestination _resolvePostAuthDestination;
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;

  Future<void> _onSendOtp(
    AuthSendOtpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true, clearNavigation: true));
    try {
      await PhoneOtpRoutePersistence.markPending(
        _prefs,
        phoneE164: event.phoneE164,
        intent: 'login',
        role: 'customer',
      );
      await _sendPhoneVerification(event.phoneE164);
      if (!_authRepository.awaitingPhoneSmsCodeEntry) {
        await PhoneOtpRoutePersistence.clear(_prefs);
        emit(state.copyWith(loading: false));
        return;
      }
      emit(
        state.copyWith(
          loading: false,
          navigateToOtpArgs: <String, dynamic>{
            'phoneE164': event.phoneE164,
            'intent': 'login',
            'role': 'customer',
          },
        ),
      );
    } on Object catch (e) {
      await PhoneOtpRoutePersistence.clear(_prefs);
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _verifySmsCode(event.code);
      await PhoneOtpRoutePersistence.clear(_prefs);
      final user = await _watchAuthState().firstWhere((u) => u != null);
      final uid = user?.uid;
      var nextRoute = AppRoutes.home;
      if (uid != null) {
        final destination = await _resolvePostAuthDestination(uid);
        if (destination == PostAuthDestination.completeProfile) {
          nextRoute = AppRoutes.signupProfile;
        }
      }
      emit(state.copyWith(loading: false, navigateToRoute: nextRoute));
    } on Object catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onResendOtp(
    AuthResendOtpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      await _sendPhoneVerification(event.phoneE164);
      await PhoneOtpRoutePersistence.markPending(
        _prefs,
        phoneE164: event.phoneE164,
        intent: event.intent,
        role: event.role,
      );
      emit(state.copyWith(loading: false));
    } on Object catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onOtpFlowCancelled(
    AuthOtpFlowCancelled event,
    Emitter<AuthBlocState> emit,
  ) async {
    _authRepository.abandonPhoneVerification();
    await PhoneOtpRoutePersistence.clear(_prefs);
    emit(state.copyWith(clearNavigation: true, clearError: true, loading: false));
  }

  void _onErrorAck(
    AuthErrorAcknowledged event,
    Emitter<AuthBlocState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearNavigation: true));
  }
}
