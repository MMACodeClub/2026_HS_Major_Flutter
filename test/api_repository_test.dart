import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mma_chat/data/repositories/api_chat_repository.dart';
import 'package:mma_chat/data/services/chat_api_client.dart';
import 'package:mma_chat/domain/app_exception.dart';

void main() {
  ApiChatRepository repository(
    Future<http.Response> Function(http.Request) handle, {
    Duration timeout = const Duration(seconds: 1),
  }) => ApiChatRepository(
    ChatApiClient(
      client: MockClient(handle),
      baseUrl: Uri.parse('https://example.org/api/'),
      timeout: timeout,
    ),
  );

  test('GET preserves base paths and decodes UTF-8', () async {
    final repo = repository((request) async {
      expect(request.url.path, '/api/chats');
      expect(request.headers['Accept'], 'application/json');
      return http.Response.bytes(
        utf8.encode('[{"_id":"1","roomId":"Grüezi 👋"}]'),
        200,
      );
    });
    addTearDown(repo.dispose);
    expect((await repo.getRooms()).single.title, 'Grüezi 👋');
  });
  test(
    'message IDs are URI path segments, not unescaped interpolation',
    () async {
      final repo = repository((request) async {
        expect(request.url.pathSegments, [
          'api',
          'chats',
          'room/a b',
          'messages',
          'm?#',
        ]);
        expect(request.url.query, isEmpty);
        expect(request.url.fragment, isEmpty);
        expect(request.method, 'DELETE');
        return http.Response('', 204);
      });
      addTearDown(repo.dispose);
      await repo.deleteMessage('room/a b', 'm?#');
    },
  );
  test(
    'all writes use the API contract and accept an empty 204 response',
    () async {
      final requests = <http.Request>[];
      final repo = repository((request) async {
        requests.add(request);
        return http.Response('', request.method == 'POST' ? 201 : 204);
      });
      addTearDown(repo.dispose);
      await repo.createRoom(' Hallo ');
      await repo.renameRoom('r', 'Neu');
      await repo.sendMessage('r', ' Hoi ');
      await repo.editMessage('r', 'm', 'Bearbeitet');
      await repo.deleteMessage('r', 'm');
      await repo.deleteRoom('r');
      expect(requests.map((r) => r.method), [
        'POST',
        'PUT',
        'POST',
        'PUT',
        'DELETE',
        'DELETE',
      ]);
      expect(jsonDecode(requests[0].body), {'roomId': 'Hallo'});
      expect(jsonDecode(requests[2].body), {'content': 'Hoi'});
      expect(requests[3].url.path, '/api/chats/r/messages/m');
      expect(requests[0].headers['Content-Type'], contains('application/json'));
    },
  );
  test('messages are returned chronologically', () async {
    final repo = repository(
      (_) async => http.Response(
        jsonEncode([
          {
            '_id': '2',
            'randomName': 'B',
            'content': 'Later',
            'timestamp': '2026-01-02T10:00:00Z',
          },
          {
            '_id': '1',
            'randomName': 'A',
            'content': 'Earlier',
            'timestamp': '2026-01-01T10:00:00Z',
          },
        ]),
        200,
      ),
    );
    addTearDown(repo.dispose);
    expect((await repo.getMessages('r')).map((m) => m.id), ['1', '2']);
  });
  test(
    'malformed payloads and model fields become presentable errors',
    () async {
      for (final body in [
        'not json',
        '{}',
        '[42]',
        '[{"_id":null,"roomId":"Oops"}]',
      ]) {
        final repo = repository((_) async => http.Response(body, 200));
        await expectLater(repo.getRooms(), throwsA(isA<AppException>()));
        repo.dispose();
      }
    },
  );
  test('server and network errors do not expose response bodies', () async {
    for (final status in [401, 404, 429, 500]) {
      final repo = repository(
        (_) async => http.Response('private server details', status),
      );
      await expectLater(
        repo.getRooms(),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            isNot(contains('private server details')),
          ),
        ),
      );
      repo.dispose();
    }
    final repo = repository(
      (_) async => throw http.ClientException('internal URL'),
    );
    addTearDown(repo.dispose);
    await expectLater(repo.getRooms(), throwsA(isA<AppException>()));
  });
  test('a stalled request times out', () async {
    final pending = Completer<http.Response>();
    final repo = repository(
      (_) => pending.future,
      timeout: const Duration(milliseconds: 5),
    );
    addTearDown(repo.dispose);
    await expectLater(
      repo.getRooms(),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          contains('rechtzeitig'),
        ),
      ),
    );
    pending.complete(http.Response('[]', 200));
  });
}
