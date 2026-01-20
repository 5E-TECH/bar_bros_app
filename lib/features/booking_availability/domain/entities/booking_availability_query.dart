import 'package:equatable/equatable.dart';

class BookingAvailabilityQuery extends Equatable {
  final String barberId;
  final String serviceId;
  final String date;

  const BookingAvailabilityQuery({
    required this.barberId,
    required this.serviceId,
    required this.date,
  });

  @override
  List<Object?> get props => [barberId, serviceId, date];
}
