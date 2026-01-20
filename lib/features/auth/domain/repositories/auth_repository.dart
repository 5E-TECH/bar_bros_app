import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/auth/domain/entities/account.dart';
import 'package:bar_bros_user/features/auth/domain/entities/register_response.dart';
import 'package:bar_bros_user/features/auth/domain/entities/set_fullname_response.dart';
import 'package:bar_bros_user/features/auth/domain/entities/verify_response.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResponse>> register(String phoneNumber);
  Future<Either<Failure, VerifyResponse>> verifyCode(String phoneNumber, String code);
  Future<Either<Failure, SetFullNameResponse>> setFullName(String fullName);
  Future<Either<Failure, Account>> getMyAccount();
}
