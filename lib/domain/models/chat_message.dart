import 'json_fields.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: requiredString(json, '_id'),
    author: requiredString(json, 'randomName'),
    content: requiredString(json, 'content'),
    sentAt: DateTime.parse(requiredString(json, 'timestamp')),
  );

  final String id;
  final String author;
  final String content;
  final DateTime sentAt;
}
