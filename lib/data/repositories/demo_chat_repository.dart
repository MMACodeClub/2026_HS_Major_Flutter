import '../../domain/app_exception.dart';
import '../../domain/input_validation.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';
import '../chat_repository.dart';

/// Session-local classroom data. Reloading the app resets this repository.
class DemoChatRepository implements ChatRepository {
  DemoChatRepository({this.latency = const Duration(milliseconds: 180)}) {
    final now = DateTime.now();
    _rooms.addAll(const [
      ChatRoom(id: 'welcome', title: 'Ankommen & Austauschen'),
      ChatRoom(id: 'flutter', title: 'Flutter-Werkstatt'),
      ChatRoom(id: 'ideas', title: 'Ideen für morgen'),
    ]);
    _messages['welcome'] = [
      ChatMessage(
        id: 'intro',
        author: 'MMA Code Club',
        content:
            'Hoi zäme! Hier ist Platz für Fragen, Ideen und euren ersten Flutter-Chat.',
        sentAt: now.subtract(const Duration(minutes: 12)),
      ),
      ChatMessage(
        id: 'question',
        author: 'Alex',
        content: 'Was wollt ihr als Erstes bauen?',
        sentAt: now.subtract(const Duration(minutes: 8)),
      ),
    ];
    _messages['flutter'] = [
      ChatMessage(
        id: 'tip',
        author: 'Sam',
        content:
            'Tipp: Ändert eine Farbe und probiert Hot Reload aus. Der Zustand bleibt erhalten.',
        sentAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
    _messages['ideas'] = [];
  }

  final Duration latency;
  final List<ChatRoom> _rooms = [];
  final Map<String, List<ChatMessage>> _messages = {};
  int _nextId = 0;

  Future<void> _wait() => Future<void>.delayed(latency);
  List<ChatMessage> _roomMessages(String id) {
    final result = _messages[id];
    if (result == null) {
      throw const AppException('Dieser Raum existiert nicht mehr.');
    }
    return result;
  }

  @override
  Future<List<ChatRoom>> getRooms() async {
    await _wait();
    return List.unmodifiable(_rooms);
  }

  @override
  Future<void> createRoom(String title) async {
    final name = requireRoomTitle(title);
    await _wait();
    final id = 'room-${++_nextId}';
    _rooms.add(ChatRoom(id: id, title: name));
    _messages[id] = [];
  }

  @override
  Future<void> renameRoom(String roomId, String title) async {
    final name = requireRoomTitle(title);
    await _wait();
    _roomMessages(roomId);
    final index = _rooms.indexWhere((room) => room.id == roomId);
    _rooms[index] = ChatRoom(id: roomId, title: name);
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    await _wait();
    _roomMessages(roomId);
    _rooms.removeWhere((room) => room.id == roomId);
    _messages.remove(roomId);
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId) async {
    await _wait();
    return List.unmodifiable(_roomMessages(roomId));
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    final text = requireMessage(content);
    await _wait();
    _roomMessages(roomId).add(
      ChatMessage(
        id: 'message-${++_nextId}',
        author: 'Du (Demo)',
        content: text,
        sentAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> editMessage(
    String roomId,
    String messageId,
    String content,
  ) async {
    final text = requireMessage(content);
    await _wait();
    final messages = _roomMessages(roomId);
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index < 0) {
      throw const AppException('Diese Nachricht existiert nicht mehr.');
    }
    final old = messages[index];
    messages[index] = ChatMessage(
      id: old.id,
      author: old.author,
      content: text,
      sentAt: old.sentAt,
    );
  }

  @override
  Future<void> deleteMessage(String roomId, String messageId) async {
    await _wait();
    final messages = _roomMessages(roomId);
    if (!messages.any((message) => message.id == messageId)) {
      throw const AppException('Diese Nachricht existiert nicht mehr.');
    }
    messages.removeWhere((message) => message.id == messageId);
  }

  @override
  void dispose() {}
}
