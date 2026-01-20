import 'package:bar_bros_user/features/barber_shop_services/domain/usecases/get_all_barber_shop_services_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'barber_shop_service_event.dart';
import 'barber_shop_service_state.dart';

@injectable
class BarberShopServiceBloc
    extends Bloc<BarberShopServiceEvent, BarberShopServiceState> {
  final GetAllBarberShopServicesUseCase _getAllUseCase;

  BarberShopServiceBloc(this._getAllUseCase)
      : super(BarberShopServiceInitial()) {
    on<GetAllBarberShopServicesEvent>(_onGetAll);
  }

  Future<void> _onGetAll(
    GetAllBarberShopServicesEvent event,
    Emitter<BarberShopServiceState> emit,
  ) async {
    emit(BarberShopServiceLoading());

    final result = await _getAllUseCase(event.query);

    result.fold(
      (failure) => emit(BarberShopServiceError(failure.message)),
      (services) => emit(BarberShopServiceLoaded(services)),
    );
  }
}
