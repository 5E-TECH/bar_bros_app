import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/service/domain/usecases/get_all_services_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'service_event.dart';
import 'service_state.dart';

@injectable
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetAllServicesUseCase _getAllServicesUseCase;

  ServiceBloc(this._getAllServicesUseCase) : super(ServiceInitial()) {
    on<GetAllServicesEvent>(_onGetAllServices);
  }

  Future<void> _onGetAllServices(
    GetAllServicesEvent event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    final result = await _getAllServicesUseCase(NoParams());

    result.fold(
      (failure) => emit(ServiceError(failure.message)),
      (services) => emit(ServiceLoaded(services)),
    );
  }
}
