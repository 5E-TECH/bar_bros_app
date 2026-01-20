import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';
import 'package:bar_bros_user/features/service/domain/repositories/service_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllServicesUseCase implements UseCase<List<Service>, NoParams> {
  final ServiceRepository _repository;

  GetAllServicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<Service>>> call(NoParams params) async {
    return await _repository.getAllServices();
  }
}
