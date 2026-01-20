import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/repositories/barber_shop_service_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllBarberShopServicesUseCase
    implements UseCase<List<BarberShopService>, BarberShopServiceQuery> {
  final BarberShopServiceRepository _repository;

  GetAllBarberShopServicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<BarberShopService>>> call(
    BarberShopServiceQuery params,
  ) async {
    return await _repository.getAllBarberShopServices(params);
  }
}
