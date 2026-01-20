import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_service_brief.dart';

class BarberServiceBriefModel extends BarberServiceBrief {
  const BarberServiceBriefModel({
    required super.id,
    required super.description,
    required super.name,
    required super.durationMinutes,
  });

  factory BarberServiceBriefModel.fromJson(Map<String, dynamic> json) {
    return BarberServiceBriefModel(
      id: json['id']?.toString() ?? '',
      description: json['description'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
    );
  }
}
