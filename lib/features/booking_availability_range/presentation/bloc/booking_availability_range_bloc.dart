import 'package:bar_bros_user/features/booking_availability_range/domain/usecases/get_booking_availability_range_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_availability_range_event.dart';
import 'booking_availability_range_state.dart';

class BookingAvailabilityRangeBloc extends Bloc<
    BookingAvailabilityRangeEvent, BookingAvailabilityRangeState> {
  final GetBookingAvailabilityRangeUseCase _getAvailabilityRangeUseCase;

  BookingAvailabilityRangeBloc(this._getAvailabilityRangeUseCase)
      : super(BookingAvailabilityRangeInitial()) {
    on<GetBookingAvailabilityRangeEvent>(_onGetAvailabilityRange);
  }

  Future<void> _onGetAvailabilityRange(
    GetBookingAvailabilityRangeEvent event,
    Emitter<BookingAvailabilityRangeState> emit,
  ) async {
    emit(BookingAvailabilityRangeLoading());
    final result = await _getAvailabilityRangeUseCase(event.query);
    result.fold(
      (failure) => emit(BookingAvailabilityRangeError(failure.message)),
      (availability) => emit(BookingAvailabilityRangeLoaded(availability)),
    );
  }
}
