import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/booking_availability_range/data/datasources/booking_availability_range_datasource.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range_query.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/repositories/booking_availability_range_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingAvailabilityRangeRepository)
class BookingAvailabilityRangeRepositoryImpl
    implements BookingAvailabilityRangeRepository {
  final BookingAvailabilityRangeRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BookingAvailabilityRangeRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
  );

  @override
  Future<Either<Failure, BookingAvailabilityRange>> getAvailabilityRange(
    BookingAvailabilityRangeQuery query,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure('No token found'));
      }
      final result = await _remoteDataSource.getAvailabilityRange(token, query);
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
