import 'package:flutter_test/flutter_test.dart';
import 'package:mma_chat/data/repositories/demo_chat_repository.dart';
import 'package:mma_chat/domain/app_exception.dart';

void main() {
  test('room and message CRUD works without a server', () async {
    final repo = DemoChatRepository(latency: Duration.zero);
    await repo.createRoom(' Test ');
    var room = (await repo.getRooms()).last;
    expect(room.title, 'Test');
    await repo.renameRoom(room.id, 'Neu');
    room = (await repo.getRooms()).last;
    expect(room.title, 'Neu');
    await repo.sendMessage(room.id, ' Hallo ');
    var message = (await repo.getMessages(room.id)).single;
    expect(message.content, 'Hallo');
    await repo.editMessage(room.id, message.id, 'Hoi');
    message = (await repo.getMessages(room.id)).single;
    expect(message.content, 'Hoi');
    await repo.deleteMessage(room.id, message.id);
    expect(await repo.getMessages(room.id), isEmpty);
    await repo.deleteRoom(room.id);
    await expectLater(repo.getMessages(room.id), throwsA(isA<AppException>()));
  });
  test('repository snapshots cannot be mutated by widgets', () async {
    final repo = DemoChatRepository(latency: Duration.zero);
    final rooms = await repo.getRooms();
    expect(rooms.clear, throwsUnsupportedError);
    await repo.createRoom('Another');
    expect(rooms.length, 3);
    expect((await repo.getRooms()).length, 4);
  });
  test('invalid writes do not alter stored data', () async {
    final repo = DemoChatRepository(latency: Duration.zero);
    await expectLater(repo.createRoom(' '), throwsA(isA<AppException>()));
    await expectLater(
      repo.sendMessage('welcome', ''),
      throwsA(isA<AppException>()),
    );
    expect((await repo.getRooms()).length, 3);
    expect((await repo.getMessages('welcome')).length, 2);
  });
}
