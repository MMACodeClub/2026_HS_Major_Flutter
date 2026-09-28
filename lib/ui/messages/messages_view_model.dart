import '../../data/chat_repository.dart';
import '../../domain/models/chat_message.dart';
import '../core/list_view_model.dart';

class MessagesViewModel extends ListViewModel<ChatMessage> {
  MessagesViewModel(this._repository, this.roomId);
  final ChatRepository _repository;
  final String roomId;
  @override
  Future<List<ChatMessage>> fetchItems() => _repository.getMessages(roomId);
  Future<bool> send(String content) =>
      mutate(() => _repository.sendMessage(roomId, content));
  Future<bool> edit(ChatMessage message, String content) =>
      mutate(() => _repository.editMessage(roomId, message.id, content));
  Future<bool> delete(ChatMessage message) =>
      mutate(() => _repository.deleteMessage(roomId, message.id));
}
