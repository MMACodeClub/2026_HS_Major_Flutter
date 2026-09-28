import 'json_fields.dart';

class ChatRoom {
  const ChatRoom({required this.id, required this.title});

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
    id: requiredString(json, '_id'),
    title: requiredString(json, 'roomId'),
  );

  final String id;
  final String title;
}
