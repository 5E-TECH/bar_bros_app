import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/auth/domain/entities/set_fullname_response.dart';
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class SetFullNameParams {
  final String fullName;

  SetFullNameParams(this.fullName);
}

@lazySingleton
class SetFullNameUseCase
    implements UseCase<SetFullNameResponse, SetFullNameParams> {
  final AuthRepository _repository;

  SetFullNameUseCase(this._repository);

  @override
  Future<Either<Failure, SetFullNameResponse>> call(
    SetFullNameParams params,
  ) async {
    if (params.fullName.isEmpty) {
      return Left(ValidationFailure(CustomExceptionsText.phoneNumberEmpty));
    }

    if (params.fullName.trim().length < 2) {
      return Left(ValidationFailure(CustomExceptionsText.fullNameLength));
    }

    return await _repository.setFullName(params.fullName);
  }
}
