part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final bool isNew;
  final String message;
  final String userId;

  const RegisterSuccess({
    required this.isNew,
    required this.message,
    required this.userId,
  });

  @override
  List<Object> get props => [isNew, message, userId];
}

class VerifySuccess extends AuthState {
  final String accessToken;
  final String refreshToken;

  const VerifySuccess({required this.accessToken, required this.refreshToken});

  @override
  List<Object> get props => [accessToken, refreshToken];
}

class SetFullNameSuccess extends AuthState {
  final String message;

  const SetFullNameSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final String? fullName;
  final String phoneNumber;

  const AuthAuthenticated({
    this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
