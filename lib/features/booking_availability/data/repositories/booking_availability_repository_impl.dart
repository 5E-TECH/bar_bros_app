import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/booking_availability/data/datasources/booking_availability_datasource.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:bar_bros_user/features/booking_availability/domain/repositories/booking_availability_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingAvailabilityRepository)
class BookingAvailabilityRepositoryImpl
    implements BookingAvailabilityRepository {
  final BookingAvailabilityRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BookingAvailabilityRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
  );

  @override
  Future<Either<Failure, BookingAvailability>> getAvailability(
    BookingAvailabilityQuery query,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getAvailability(token, query);
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
