import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:dartz/dartz.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, List<Category>>> getAllManCategories();
  Future<Either<Failure, List<Category>>> getAllWomanCategories();
}
