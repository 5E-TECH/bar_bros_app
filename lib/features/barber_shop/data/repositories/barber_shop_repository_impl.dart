import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/barber_shop/data/datasources/barber_shop_datasource.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/repositories/barber_shop_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: BarberShopRepository)
class BarberShopRepositoryImpl implements BarberShopRepository {
  final BarberShopRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  BarberShopRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, List<BarberShopItem>>> getBarberShops(
    BarberShopQuery query,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getBarberShops(token, query);
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
