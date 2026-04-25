import 'package:equatable/equatable.dart';

class AuthBlocState extends Equatable {
  const AuthBlocState({
    this.loading = false,
    this.errorMessage,
    this.navigateToOtpArgs,
    this.navigateToRoute,
  });

  final bool loading;
  final String? errorMessage;
  final Map<String, dynamic>? navigateToOtpArgs;
  final String? navigateToRoute;

  AuthBlocState copyWith({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? navigateToOtpArgs,
    String? navigateToRoute,
    bool clearNavigation = false,
  }) {
    return AuthBlocState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateToOtpArgs: clearNavigation
          ? null
          : (navigateToOtpArgs ?? this.navigateToOtpArgs),
      navigateToRoute: clearNavigation
          ? null
          : (navigateToRoute ?? this.navigateToRoute),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        loading,
        errorMessage,
        navigateToOtpArgs,
        navigateToRoute,
      ];
}
