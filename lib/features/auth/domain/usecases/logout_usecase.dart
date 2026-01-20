import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LogOutUseCase implements UseCase<void, NoParams> {
  final LocalStorage _localStorage;

  LogOutUseCase(this._localStorage);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _localStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
