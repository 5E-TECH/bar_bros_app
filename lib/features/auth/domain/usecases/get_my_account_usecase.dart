import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/auth/domain/entities/account.dart';
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetMyAccountUseCase implements UseCase<Account, NoParams> {
  final AuthRepository _repository;

  GetMyAccountUseCase(this._repository);

  @override
  Future<Either<Failure, Account>> call(NoParams params) async {
    return await _repository.getMyAccount();
  }
}
