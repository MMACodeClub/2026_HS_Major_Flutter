import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_chat/domain/app_exception.dart';
import 'package:mma_chat/data/repositories/demo_chat_repository.dart';
import 'package:mma_chat/ui/core/list_view_model.dart';
import 'package:mma_chat/ui/rooms/rooms_view_model.dart';
import 'package:mma_chat/ui/messages/messages_view_model.dart';

class ControlledModel extends ListViewModel<String> {
  Future<List<String>> Function() loader = () async => ['existing'];
  @override
  Future<List<String>> fetchItems() => loader();
  Future<bool> save(Future<void> Function() action) => mutate(action);
}

void main() {
  test(
    'refresh errors preserve existing data and a later retry recovers',
    () async {
      final model = ControlledModel();
      addTearDown(model.dispose);
      await model.load();
      model.loader = () async => throw const AppException('Offline');
      await model.load();
      expect(model.items, ['existing']);
      expect(model.error, 'Offline');
      expect(model.isBusy, isFalse);
      model.loader = () async => ['new'];
      await model.load();
      expect(model.items, ['new']);
      expect(model.error, isNull);
    },
  );
  test('duplicate writes and overlapping loads are suppressed', () async {
    final model = ControlledModel();
    addTearDown(model.dispose);
    final pending = Completer<void>();
    var writes = 0;
    final first = model.save(() {
      writes++;
      return pending.future;
    });
    final second = await model.save(() async {
      writes++;
    });
    await model.load();
    expect(second, isFalse);
    expect(writes, 1);
    expect(model.isSaving, isTrue);
    pending.complete();
    expect(await first, isTrue);
    expect(model.items, ['existing']);
  });
  test('successful write plus failed refresh remains a success', () async {
    final model = ControlledModel();
    addTearDown(model.dispose);
    model.loader = () async => throw const AppException('Offline');
    expect(await model.save(() async {}), isTrue);
    expect(model.error, startsWith('Gespeichert.'));
    expect(model.isBusy, isFalse);
  });
  test('failed writes return false so the UI can retain the draft', () async {
    final model = ControlledModel();
    addTearDown(model.dispose);
    expect(
      await model.save(() async => throw const AppException('Offline')),
      isFalse,
    );
    expect(model.error, 'Offline');
    expect(model.isBusy, isFalse);
  });
  test('completing a load after dispose never notifies listeners', () async {
    final model = ControlledModel();
    final pending = Completer<List<String>>();
    model.loader = () => pending.future;
    var notifications = 0;
    model.addListener(() => notifications++);
    final load = model.load();
    model.dispose();
    pending.complete(['late']);
    await load;
    expect(notifications, 1);
    expect(model.items, isEmpty);
  });
  test('completing a write after dispose does not refresh or notify', () async {
    final model = ControlledModel();
    final pending = Completer<void>();
    var fetches = 0;
    model.loader = () async {
      fetches++;
      return [];
    };
    final save = model.save(() => pending.future);
    model.dispose();
    pending.complete();
    expect(await save, isTrue);
    expect(fetches, 0);
  });
  test(
    'feature view models use the injected repository for every operation',
    () async {
      final repository = DemoChatRepository(latency: Duration.zero);
      final rooms = RoomsViewModel(repository);
      addTearDown(rooms.dispose);
      await rooms.load();
      expect(await rooms.create('VM Room'), isTrue);
      final room = rooms.items.last;
      expect(await rooms.rename(room, 'Renamed'), isTrue);
      expect(rooms.items.last.title, 'Renamed');
      final messages = MessagesViewModel(repository, room.id);
      addTearDown(messages.dispose);
      await messages.load();
      expect(await messages.send('First'), isTrue);
      expect(await messages.edit(messages.items.single, 'Changed'), isTrue);
      expect(messages.items.single.content, 'Changed');
      expect(await messages.delete(messages.items.single), isTrue);
      expect(messages.items, isEmpty);
      expect(await rooms.delete(room), isTrue);
      expect(rooms.items.length, 3);
    },
  );
}
