import '../domain/models/chat_message.dart';
import '../domain/models/chat_room.dart';

/// The UI does not need to know whether data comes from memory or HTTP.
abstract interface class ChatRepository {
  Future<List<ChatRoom>> getRooms();
  Future<void> createRoom(String title);
  Future<void> renameRoom(String roomId, String title);
  Future<void> deleteRoom(String roomId);
  Future<List<ChatMessage>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Future<void> editMessage(String roomId, String messageId, String content);
  Future<void> deleteMessage(String roomId, String messageId);
  void dispose();
}
