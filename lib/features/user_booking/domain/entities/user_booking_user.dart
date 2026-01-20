import 'package:equatable/equatable.dart';

class UserBookingUser extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String avatarImage;

  const UserBookingUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.avatarImage,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        role,
        avatarImage,
      ];
}
