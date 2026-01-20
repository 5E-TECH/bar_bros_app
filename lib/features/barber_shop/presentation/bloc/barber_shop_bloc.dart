import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'barber_shop_event.dart';
import 'barber_shop_state.dart';

@injectable
class BarberShopBloc extends Bloc<BarberShopEvent, BarberShopState> {
  final GetBarberShopsUseCase _getBarberShopsUseCase;

  BarberShopBloc(this._getBarberShopsUseCase) : super(BarberShopInitial()) {
    on<GetBarberShopsEvent>(_onGetBarberShops);
  }

  Future<void> _onGetBarberShops(
    GetBarberShopsEvent event,
    Emitter<BarberShopState> emit,
  ) async {
    emit(BarberShopLoading());
    final result = await _getBarberShopsUseCase(event.query);
    result.fold(
      (failure) => emit(BarberShopError(failure.message)),
      (shops) => emit(BarberShopLoaded(shops)),
    );
  }
}
