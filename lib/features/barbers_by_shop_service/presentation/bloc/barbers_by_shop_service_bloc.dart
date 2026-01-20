import 'package:bar_bros_user/features/barbers_by_shop_service/domain/usecases/get_barbers_by_shop_service_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'barbers_by_shop_service_event.dart';
import 'barbers_by_shop_service_state.dart';

class BarbersByShopServiceBloc
    extends Bloc<BarbersByShopServiceEvent, BarbersByShopServiceState> {
  final GetBarbersByShopServiceUseCase _getBarbersUseCase;

  BarbersByShopServiceBloc(this._getBarbersUseCase)
      : super(BarbersByShopServiceInitial()) {
    on<GetBarbersByShopServiceEvent>(_onGetBarbers);
  }

  Future<void> _onGetBarbers(
    GetBarbersByShopServiceEvent event,
    Emitter<BarbersByShopServiceState> emit,
  ) async {
    emit(BarbersByShopServiceLoading());
    final result = await _getBarbersUseCase(event.query);
    result.fold(
      (failure) => emit(BarbersByShopServiceError(failure.message)),
      (barbers) => emit(BarbersByShopServiceLoaded(barbers)),
    );
  }
}
