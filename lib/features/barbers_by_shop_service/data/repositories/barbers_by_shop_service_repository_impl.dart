import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/data/datasources/barbers_by_shop_service_datasource.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_by_shop_service.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/repositories/barbers_by_shop_service_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BarbersByShopServiceRepository)
class BarbersByShopServiceRepositoryImpl
    implements BarbersByShopServiceRepository {
  final BarbersByShopServiceRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BarbersByShopServiceRepositoryImpl(
    this._remoteDataSource,
    this._localStorage,
  );

  @override
  Future<Either<Failure, List<BarberByShopService>>> getBarbersByShopService(
    BarbersByShopServiceQuery query,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getBarbersByShopService(
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
