import '../../data/chat_repository.dart';
import '../../domain/models/chat_room.dart';
import '../core/list_view_model.dart';

class RoomsViewModel extends ListViewModel<ChatRoom> {
  RoomsViewModel(this._repository);
  final ChatRepository _repository;
  @override
  Future<List<ChatRoom>> fetchItems() => _repository.getRooms();
  Future<bool> create(String title) =>
      mutate(() => _repository.createRoom(title));
  Future<bool> rename(ChatRoom room, String title) =>
      mutate(() => _repository.renameRoom(room.id, title));
  Future<bool> delete(ChatRoom room) =>
      mutate(() => _repository.deleteRoom(room.id));
}
