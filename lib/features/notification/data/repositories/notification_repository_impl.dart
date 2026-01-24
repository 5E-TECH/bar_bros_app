import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/notification/data/datasources/notification_datasource.dart';
import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';
import 'package:bar_bros_user/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  NotificationRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, List<NotificationItem>>> getMyNotifications() async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getMyNotifications(token);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<String?> getBarberNameById(String barberId) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) return null;
      return await _remoteDataSource.getBarberNameById(token, barberId);
    } catch (e) {
      return null;
    }
  }
}
