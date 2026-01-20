import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getConversation({
    required String userId,
    required String barberId,
  });

  Future<Either<Failure, List<ChatThread>>> getMyChats();

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String message,
    required String barberId,
    String? imagePath,
  });
}
