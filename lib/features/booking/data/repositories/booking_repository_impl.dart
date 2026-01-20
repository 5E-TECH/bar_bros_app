import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/booking/data/datasources/booking_datasource.dart';
import 'package:bar_bros_user/features/booking/domain/entities/booking.dart';
import 'package:bar_bros_user/features/booking/domain/repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BookingRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, Booking>> createBooking({
    required int serviceId,
    required int barberId,
    required int barberShopId,
    required String date,
    required String time,
    required String paymentModel,
    required String orderType,
  }) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("Token topilmadi"));
      }

      final result = await _remoteDataSource.createBooking(
        token: token,
        serviceId: serviceId,
        barberId: barberId,
        barberShopId: barberShopId,
        date: date,
        time: time,
        paymentModel: paymentModel,
        orderType: orderType,
      );

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