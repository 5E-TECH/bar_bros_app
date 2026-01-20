import 'package:equatable/equatable.dart';

class UserBookingBarber extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String bio;
  final String avgReyting;
  final String img;
  final bool isAvailable;

  const UserBookingBarber({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bio,
    required this.avgReyting,
    required this.img,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        bio,
        avgReyting,
        img,
        isAvailable,
      ];
}
