import '../base/index.dart';

class AuthSendOtpRequested extends BaseEvent {
  const AuthSendOtpRequested({
    required this.phoneE164,
  });

  final String phoneE164;

  @override
  List<Object?> get props => <Object?>[phoneE164];
}

class AuthVerifyOtpRequested extends BaseEvent {
  const AuthVerifyOtpRequested(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

class AuthResendOtpRequested extends BaseEvent {
  const AuthResendOtpRequested({
    required this.phoneE164,
    required this.intent,
    required this.role,
  });

  final String phoneE164;
  final String intent;
  final String role;

  @override
  List<Object?> get props => <Object?>[phoneE164, intent, role];
}

class AuthErrorAcknowledged extends BaseEvent {
  const AuthErrorAcknowledged();
}

class AuthOtpFlowCancelled extends BaseEvent {
  const AuthOtpFlowCancelled();
}
