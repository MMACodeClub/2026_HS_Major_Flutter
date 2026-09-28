import '../../domain/app_exception.dart';
import '../../domain/input_validation.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';
import '../chat_repository.dart';
import '../services/chat_api_client.dart';

class ApiChatRepository implements ChatRepository {
  ApiChatRepository(this._api);
  final ChatApiClient _api;

  @override
  Future<List<ChatRoom>> getRooms() async {
    final data = await _api.getList(['chats']);
    return _parse(() => data.map(ChatRoom.fromJson).toList());
  }

  @override
  Future<void> createRoom(String title) =>
      _api.write('POST', ['chats'], body: {'roomId': requireRoomTitle(title)});
  @override
  Future<void> renameRoom(String roomId, String title) => _api.write(
    'PUT',
    ['chats', roomId],
    body: {'roomId': requireRoomTitle(title)},
  );
  @override
  Future<void> deleteRoom(String roomId) =>
      _api.write('DELETE', ['chats', roomId]);
  @override
  Future<List<ChatMessage>> getMessages(String roomId) async {
    final data = await _api.getList(['chats', roomId, 'messages']);
    final messages = _parse(() => data.map(ChatMessage.fromJson).toList());
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  @override
  Future<void> sendMessage(String roomId, String content) => _api.write(
    'POST',
    ['chats', roomId, 'messages'],
    body: {'content': requireMessage(content)},
  );
  @override
  Future<void> editMessage(String roomId, String messageId, String content) =>
      _api.write(
        'PUT',
        ['chats', roomId, 'messages', messageId],
        body: {'content': requireMessage(content)},
      );
  @override
  Future<void> deleteMessage(String roomId, String messageId) =>
      _api.write('DELETE', ['chats', roomId, 'messages', messageId]);
  @override
  void dispose() => _api.dispose();

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const AppException(
        'Die Daten des Servers passen nicht zum erwarteten Format.',
      );
    }
  }
}
