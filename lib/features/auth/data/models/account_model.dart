import 'package:bar_bros_user/features/auth/domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.phoneNumber,
    super.fullName,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'].toString(),
      phoneNumber: json['phone_number'] as String,
      fullName: json['full_name'] as String?,
    );
  }
}
