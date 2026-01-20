import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetMyChatsUseCase implements UseCase<List<ChatThread>, NoParams> {
  final ChatRepository _repository;

  GetMyChatsUseCase(this._repository);

  @override
  Future<Either<Failure, List<ChatThread>>> call(NoParams params) async {
    return await _repository.getMyChats();
  }
}
