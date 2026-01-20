import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/barber_shop_services/data/datasources/barber_shop_service_datasource.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/repositories/barber_shop_service_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BarberShopServiceRepository)
class BarberShopServiceRepositoryImpl implements BarberShopServiceRepository {
  final BarberShopServiceRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BarberShopServiceRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, List<BarberShopService>>> getAllBarberShopServices(
    BarberShopServiceQuery query,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getAllBarberShopServices(
        token,
        query,
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
