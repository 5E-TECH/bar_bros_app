import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String? fullName;
  final String phoneNumber;

  const Account({
    required this.id,
    this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber];
}
