import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/category/data/datasources/category_datasource.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  CategoryRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    return _handleRequest(_remoteDataSource.getAllCategories);
  }

  @override
  Future<Either<Failure, List<Category>>> getAllManCategories() async {
    return _handleRequest(_remoteDataSource.getAllManCategories);
  }

  @override
  Future<Either<Failure, List<Category>>> getAllWomanCategories() async {
    return _handleRequest(_remoteDataSource.getAllWomanCategories);
  }

  Future<Either<Failure, List<Category>>> _handleRequest(
    Future<List<Category>> Function(String token) request,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await request(token);
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
