import 'package:equatable/equatable.dart';

class UserBookingService extends Equatable {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;

  const UserBookingService({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        durationMinutes,
      ];
}
