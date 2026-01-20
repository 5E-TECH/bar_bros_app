import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/chat/data/datasources/chat_datasource.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  ChatRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<Either<Failure, List<ChatMessage>>> getConversation({
    required String userId,
    required String barberId,
  }) async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getConversation(
        token,
        userId: userId,
        barberId: barberId,
      );
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
  Future<Either<Failure, List<ChatThread>>> getMyChats() async {
    try {
      final token = await _localStorage.getToken();
      if (token == null) {
        return const Left(CacheFailure("No token found"));
      }
      final result = await _remoteDataSource.getMyChats(token);
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
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required String barberId,
    String? imagePath,
  }) async {
    try {
      final token = await _localStorage.getToken();
      final userId = await _localStorage.getUserId();
      if (token == null || userId == null || userId.isEmpty) {
        return const Left(CacheFailure("No user found"));
      }
      final result = await _remoteDataSource.sendMessage(
        token,
        message: message,
        userId: userId,
        barberId: barberId,
        imagePath: imagePath,
      );
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
