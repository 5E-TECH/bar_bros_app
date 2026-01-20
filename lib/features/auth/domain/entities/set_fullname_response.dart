import 'package:equatable/equatable.dart';

class SetFullNameResponse extends Equatable {
  final String message;
  final String accessToken;
  final String refreshToken;

  const SetFullNameResponse({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [message, accessToken, refreshToken];
}
