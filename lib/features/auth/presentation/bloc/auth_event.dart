part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String phoneNumber;

  const RegisterEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyCodeEvent extends AuthEvent {
  final String phoneNumber;
  final String code;
  final bool isNewUser;

  const VerifyCodeEvent({
    required this.phoneNumber,
    required this.code,
    required this.isNewUser,
  });

  @override
  List<Object> get props => [phoneNumber, code, isNewUser];
}

class SetFullNameEvent extends AuthEvent {
  final String fullName;

  const SetFullNameEvent(this.fullName);

  @override
  List<Object> get props => [fullName];
}

class ResetAuthEvent extends AuthEvent {
  const ResetAuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
