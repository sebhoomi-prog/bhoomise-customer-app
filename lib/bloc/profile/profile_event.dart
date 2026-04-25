import '../../features/profile/domain/entities/user_profile.dart';
import '../base/index.dart';

class ProfileStarted extends BaseEvent {
  const ProfileStarted({required this.isSignup});

  final bool isSignup;

  @override
  List<Object?> get props => <Object?>[isSignup];
}

class ProfileAuthChanged extends BaseEvent {
  const ProfileAuthChanged({required this.uid, required this.phoneNumber});

  final String? uid;
  final String? phoneNumber;

  @override
  List<Object?> get props => <Object?>[uid, phoneNumber];
}

class ProfileLoaded extends BaseEvent {
  const ProfileLoaded(this.profile);

  final UserProfile? profile;

  @override
  List<Object?> get props => <Object?>[profile];
}

class ProfileSubmitRequested extends BaseEvent {
  const ProfileSubmitRequested({
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String? email;

  @override
  List<Object?> get props => <Object?>[displayName, email];
}

class ProfileSignOutRequested extends BaseEvent {
  const ProfileSignOutRequested();
}

class ProfileUiFlagsCleared extends BaseEvent {
  const ProfileUiFlagsCleared();
}
