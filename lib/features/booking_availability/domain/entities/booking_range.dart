import 'package:equatable/equatable.dart';

class BookingRange extends Equatable {
  final String start;
  final String end;

  const BookingRange({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];
}
