import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/auth/domain/entities/verify_response.dart';
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class VerifyCodeParams {
  final String phoneNumber;
  final String code;

  VerifyCodeParams({required this.phoneNumber, required this.code});
}

@lazySingleton
class VerifyCodeUseCase implements UseCase<VerifyResponse, VerifyCodeParams> {
  final AuthRepository _repository;

  VerifyCodeUseCase(this._repository);

  @override
  Future<Either<Failure, VerifyResponse>> call(VerifyCodeParams params) async {
    if (params.phoneNumber.isEmpty) {
      return Left(ValidationFailure(CustomExceptionsText.phoneNumberEmpty));
    }

    if (params.code.isEmpty) {
      return Left(ValidationFailure(CustomExceptionsText.codeEmpty));
    }

    if (params.code.length != 4) {
      return Left(ValidationFailure(CustomExceptionsText.codeMust4));
    }

    return await _repository.verifyCode(params.phoneNumber, params.code);
  }
}
