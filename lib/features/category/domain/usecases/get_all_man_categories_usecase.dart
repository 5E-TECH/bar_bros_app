import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllManCategoriesUseCase
    implements UseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;

  GetAllManCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await _repository.getAllManCategories();
  }
}
