import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CheckAuthUseCase implements UseCase<bool, NoParams> {
  final LocalStorage _localStorage;

  CheckAuthUseCase(this._localStorage);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final token = await _localStorage.getToken();
      final userId = await _localStorage.getUserId();

      return Right(
        token != null &&
            token.isNotEmpty &&
            userId != null &&
            userId.isNotEmpty,
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
