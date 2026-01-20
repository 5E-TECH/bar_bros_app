import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/auth/domain/entities/register_response.dart';
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class RegisterParams {
  final String phoneNumber;

  RegisterParams(this.phoneNumber);
}

@lazySingleton
class RegisterUseCase implements UseCase<RegisterResponse, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, RegisterResponse>> call(RegisterParams params) async {
    if (params.phoneNumber.isEmpty) {
      return Left(ValidationFailure(CustomExceptionsText.phoneNumberEmpty));
    }

    if (!_isValidPhoneNumber(params.phoneNumber)) {
      return Left(ValidationFailure(CustomExceptionsText.invalidPhone));
    }
    return await _repository.register(params.phoneNumber);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r"^\+998\d{9}$");
    return regex.hasMatch(phoneNumber);
  }
}
