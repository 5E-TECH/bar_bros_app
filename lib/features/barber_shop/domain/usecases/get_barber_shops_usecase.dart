import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/repositories/barber_shop_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetBarberShopsUseCase
    implements UseCase<List<BarberShopItem>, BarberShopQuery> {
  final BarberShopRepository _repository;

  GetBarberShopsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BarberShopItem>>> call(
    BarberShopQuery params,
  ) async {
    return await _repository.getBarberShops(params);
  }
}
