import 'package:equatable/equatable.dart';

class BarberServiceBrief extends Equatable {
  final String id;
  final String description;
  final String name;
  final int durationMinutes;

  const BarberServiceBrief({
    required this.id,
    required this.description,
    required this.name,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        name,
        durationMinutes,
      ];
}
