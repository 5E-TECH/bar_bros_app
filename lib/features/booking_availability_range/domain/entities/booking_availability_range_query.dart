import 'package:equatable/equatable.dart';

class BookingAvailabilityRangeQuery extends Equatable {
  final String barberId;
  final String from;
  final String to;
  final String serviceId;

  const BookingAvailabilityRangeQuery({
    required this.barberId,
    required this.from,
    required this.to,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [
        barberId,
        from,
        to,
        serviceId,
      ];
}
