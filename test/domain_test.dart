import 'package:flutter_test/flutter_test.dart';
import 'package:mma_chat/config/app_config.dart';
import 'package:mma_chat/domain/app_exception.dart';
import 'package:mma_chat/domain/input_validation.dart';
import 'package:mma_chat/domain/models/chat_message.dart';
import 'package:mma_chat/domain/models/chat_room.dart';

void main() {
  test('API fields map to immutable domain models', () {
    final room = ChatRoom.fromJson({'_id': '1', 'roomId': 'Flutter', '__v': 0});
    expect(room.id, '1');
    expect(room.title, 'Flutter');
    final message = ChatMessage.fromJson({
      '_id': 'm',
      'randomName': 'Ada',
      'content': 'Hoi',
      'timestamp': '2026-09-28T12:00:00Z',
    });
    expect(message.sentAt.isUtc, isTrue);
  });
  test('missing or invalid IDs fail instead of using an empty fallback', () {
    for (final id in [null, '', '  ', 7]) {
      expect(
        () => ChatRoom.fromJson({'_id': id, 'roomId': 'Flutter'}),
        throwsFormatException,
      );
    }
  });
  test('invalid dates and message fields fail early', () {
    expect(
      () => ChatMessage.fromJson({
        '_id': 'm',
        'randomName': 'Ada',
        'content': 'Hoi',
        'timestamp': 'bad-date',
      }),
      throwsFormatException,
    );
    expect(
      () => ChatMessage.fromJson({
        '_id': 'm',
        'randomName': 42,
        'content': 'Hoi',
        'timestamp': '2026-01-01',
      }),
      throwsFormatException,
    );
  });
  test('input validation is shared between UI and repositories', () {
    expect(requireRoomTitle('  Flutter  '), 'Flutter');
    expect(() => requireMessage('  '), throwsA(isA<AppException>()));
    expect(validateRoomTitle('a' * 81), isNotNull);
    expect(validateMessage('a' * 2000), isNull);
    expect(validateMessage('a' * 2001), isNotNull);
  });
  test(
    'configuration defaults to demo; API requires a valid public base URL',
    () {
      expect(AppConfig.parse(mode: 'demo', url: '').isDemo, isTrue);
      expect(
        AppConfig.parse(
          mode: 'api',
          url: 'https://example.org/api/',
        ).apiBaseUrl!.path,
        '/api/',
      );
      expect(
        AppConfig.parse(mode: 'api', url: 'http://localhost:8080').isDemo,
        isFalse,
      );
      for (final url in [
        'http://example.org',
        'file:///tmp',
        'https://user:secret@example.org',
        'https://example.org/?key=secret',
        'https://example.org/#fragment',
        'bad',
      ]) {
        expect(
          () => AppConfig.parse(mode: 'api', url: url),
          throwsFormatException,
        );
      }
      expect(
        () => AppConfig.parse(mode: 'typo', url: ''),
        throwsFormatException,
      );
    },
  );
}
