import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class GetChatConversationParams {
  final String userId;
  final String barberId;

  GetChatConversationParams({
    required this.userId,
    required this.barberId,
  });
}

@lazySingleton
class GetChatConversationUseCase
    implements UseCase<List<ChatMessage>, GetChatConversationParams> {
  final ChatRepository _repository;

  GetChatConversationUseCase(this._repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(
    GetChatConversationParams params,
  ) async {
    return await _repository.getConversation(
      userId: params.userId,
      barberId: params.barberId,
    );
  }
}
