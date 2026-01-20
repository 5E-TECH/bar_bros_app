import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

class SendMessageParams {
  final String message;
  final String barberId;
  final String? imagePath;

  SendMessageParams({
    required this.message,
    required this.barberId,
    this.imagePath,
  });
}

@lazySingleton
class SendMessageUseCase implements UseCase<ChatMessage, SendMessageParams> {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    return await _repository.sendMessage(
      message: params.message,
      barberId: params.barberId,
      imagePath: params.imagePath,
    );
  }
}