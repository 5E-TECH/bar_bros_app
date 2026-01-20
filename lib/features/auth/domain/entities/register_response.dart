import 'package:equatable/equatable.dart';

class RegisterResponse extends Equatable {
  final bool isNew;
  final String message;
  final String userId;
  final String? verificationToken;

  const RegisterResponse({
    required this.isNew,
    required this.message,
    required this.userId,
    this.verificationToken,
  });

  @override
  List<Object?> get props => [isNew, message, userId, verificationToken];
}
