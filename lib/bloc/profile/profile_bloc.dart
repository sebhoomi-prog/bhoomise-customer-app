import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/save_user_profile.dart';
import '../base/index.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<BaseEvent, ProfileBlocState> {
  ProfileBloc(
    this._watchAuthState,
    this._getUserProfile,
    this._saveUserProfile,
    this._signOut,
  ) : super(const ProfileBlocState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileAuthChanged>(_onAuthChanged);
    on<ProfileLoaded>(_onProfileLoaded);
    on<ProfileSubmitRequested>(_onSubmitRequested);
    on<ProfileSignOutRequested>(_onSignOutRequested);
    on<ProfileUiFlagsCleared>(_onUiFlagsCleared);
  }

  final WatchAuthState _watchAuthState;
  final GetUserProfile _getUserProfile;
  final SaveUserProfile _saveUserProfile;
  final SignOut _signOut;

  StreamSubscription<dynamic>? _authSub;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileBlocState> emit,
  ) async {
    emit(state.copyWith(isSignup: event.isSignup, clearNavigateRoute: true));
    await _authSub?.cancel();
    _authSub = _watchAuthState().listen((user) {
      add(ProfileAuthChanged(uid: user?.uid, phoneNumber: user?.phoneNumber));
    });
  }

  Future<void> _onAuthChanged(
    ProfileAuthChanged event,
    Emitter<ProfileBlocState> emit,
  ) async {
    if (event.uid == null) {
      emit(
        state.copyWith(
          clearUid: true,
          clearPhoneNumber: true,
          clearProfile: true,
          loading: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        uid: event.uid,
        phoneNumber: event.phoneNumber,
        loading: true,
      ),
    );
    final profile = await _getUserProfile(event.uid!);
    add(ProfileLoaded(profile));
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileBlocState> emit,
  ) async {
    emit(state.copyWith(profile: event.profile, loading: false));
  }

  Future<void> _onSubmitRequested(
    ProfileSubmitRequested event,
    Emitter<ProfileBlocState> emit,
  ) async {
    final uid = state.uid;
    if (uid == null) {
      emit(state.copyWith(errorMessage: AppStrings.signInToContinue));
      return;
    }
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearNavigateRoute: true,
        closeCurrentPage: false,
      ),
    );
    final trimmedEmail = event.email?.trim();
    final profile = UserProfile(
      uid: uid,
      displayName: event.displayName.trim(),
      email: (trimmedEmail == null || trimmedEmail.isEmpty)
          ? null
          : trimmedEmail,
      phoneNumber: state.phoneNumber,
      profileCompleted: true,
    );
    await _saveUserProfile(profile);
    if (state.isSignup) {
      emit(
        state.copyWith(
          loading: false,
          navigateToRoute: AppRoutes.home,
        ),
      );
      return;
    }
    emit(
      state.copyWith(loading: false, profile: profile, closeCurrentPage: true),
    );
  }

  Future<void> _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileBlocState> emit,
  ) async {
    await _signOut();
  }

  Future<void> _onUiFlagsCleared(
    ProfileUiFlagsCleared event,
    Emitter<ProfileBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        clearError: true,
        clearNavigateRoute: true,
        closeCurrentPage: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
