import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_by_shop_service.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:dartz/dartz.dart';

abstract class BarbersByShopServiceRepository {
  Future<Either<Failure, List<BarberByShopService>>> getBarbersByShopService(
    BarbersByShopServiceQuery query,
  );
}
