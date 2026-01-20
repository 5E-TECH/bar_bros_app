import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/user_booking/data/datasources/user_booking_datasource.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:bar_bros_user/features/user_booking/domain/repositories/user_booking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserBookingRepository)
class UserBookingRepositoryImpl implements UserBookingRepository {
  final UserBookingRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  UserBookingRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
  );

  @override
  Future<Either<Failure, List<UserBooking>>> getUserBookings() async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure('No token found'));
      }
      final result = await _remoteDataSource.getUserBookings(token);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
