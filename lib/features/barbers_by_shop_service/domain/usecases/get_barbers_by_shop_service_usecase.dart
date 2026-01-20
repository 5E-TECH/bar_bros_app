import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_by_shop_service.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/repositories/barbers_by_shop_service_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:bar_bros_user/core/error/failure.dart';

class GetBarbersByShopServiceUseCase
    implements UseCase<List<BarberByShopService>, BarbersByShopServiceQuery> {
  final BarbersByShopServiceRepository _repository;

  GetBarbersByShopServiceUseCase(this._repository);

  @override
  Future<Either<Failure, List<BarberByShopService>>> call(
    BarbersByShopServiceQuery params,
  ) async {
    return await _repository.getBarbersByShopService(params);
  }
}
