import '../../features/profile/domain/entities/user_profile.dart';

class ProfileBlocState {
  const ProfileBlocState({
    this.isSignup = false,
    this.uid,
    this.phoneNumber,
    this.profile,
    this.loading = false,
    this.errorMessage,
    this.navigateToRoute,
    this.closeCurrentPage = false,
  });

  final bool isSignup;
  final String? uid;
  final String? phoneNumber;
  final UserProfile? profile;
  final bool loading;
  final String? errorMessage;
  final String? navigateToRoute;
  final bool closeCurrentPage;

  ProfileBlocState copyWith({
    bool? isSignup,
    String? uid,
    bool clearUid = false,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    UserProfile? profile,
    bool clearProfile = false,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    String? navigateToRoute,
    bool clearNavigateRoute = false,
    bool? closeCurrentPage,
  }) {
    return ProfileBlocState(
      isSignup: isSignup ?? this.isSignup,
      uid: clearUid ? null : (uid ?? this.uid),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      profile: clearProfile ? null : (profile ?? this.profile),
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateToRoute: clearNavigateRoute
          ? null
          : (navigateToRoute ?? this.navigateToRoute),
      closeCurrentPage: closeCurrentPage ?? this.closeCurrentPage,
    );
  }
}
