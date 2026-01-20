import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/auth/data/datasources/auth_datasource.dart';
import 'package:bar_bros_user/features/auth/domain/entities/account.dart';
import 'package:bar_bros_user/features/auth/domain/entities/register_response.dart';
import 'package:bar_bros_user/features/auth/domain/entities/set_fullname_response.dart';
import 'package:bar_bros_user/features/auth/domain/entities/verify_response.dart';
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import "package:injectable/injectable.dart";


@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, RegisterResponse>> register(String phoneNumber) async {
    try {
      final result = await _remoteDataSource.register(phoneNumber);
      await _localStorage.saveUserId(result.userId);
      if (result.verificationToken != null &&
          result.verificationToken!.isNotEmpty) {
        await _localStorage.saveVerificationToken(result.verificationToken!);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SetFullNameResponse>> setFullName(
    String fullName,
  ) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }

      final result = await _remoteDataSource.setFullName(fullName, token);
      // Only save tokens if API returns new ones (non-empty)
      if (result.accessToken.isNotEmpty) {
        await _localStorage.saveToken(result.accessToken);
      }
      if (result.refreshToken.isNotEmpty) {
        await _localStorage.saveRefreshToken(result.refreshToken);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyResponse>> verifyCode(
    String phoneNumber,
    String code,
  ) async {
    try {
      final verifyToken = await _localStorage.getVerificationToken();
      final result = await _remoteDataSource.verifyCode(
        phoneNumber,
        code,
        token: verifyToken,
      );
      if (result.accessToken.isEmpty || result.refreshToken.isEmpty) {
        return const Left(ServerFailure("Invalid token response"));
      }
      await _localStorage.saveToken(result.accessToken);
      await _localStorage.saveRefreshToken(result.refreshToken);
      await _localStorage.clearVerificationToken();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> getMyAccount() async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getMyAccount(token);
      await _localStorage.saveUserFullName(result.fullName ?? '');
      await _localStorage.saveUserId(result.id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
