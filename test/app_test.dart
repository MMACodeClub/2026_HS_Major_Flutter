import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_chat/app.dart';
import 'package:mma_chat/data/repositories/demo_chat_repository.dart';
import 'package:mma_chat/domain/app_exception.dart';

class FailingSendRepository extends DemoChatRepository {
  FailingSendRepository() : super(latency: Duration.zero);
  @override
  Future<void> sendMessage(String roomId, String content) async =>
      throw const AppException('Offline');
}

void main() {
  Future<void> revealRoom(WidgetTester tester, String title) async {
    await tester.scrollUntilVisible(
      find.text(title),
      200,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> start(
    WidgetTester tester, {
    DemoChatRepository? repository,
  }) async {
    await tester.pumpWidget(
      ChatApp(
        repository: repository ?? DemoChatRepository(latency: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('create, rename, and delete a room through the UI', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Neuer Raum'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Studierendenraum');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    await revealRoom(tester, 'Studierendenraum');
    expect(find.text('Studierendenraum'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Optionen für Studierendenraum'));
    await tester.tap(find.byTooltip('Optionen für Studierendenraum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umbenennen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Lerngruppe');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.text('Lerngruppe'), findsOneWidget);
    await tester.tap(find.byTooltip('Optionen für Lerngruppe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raum löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(find.text('Lerngruppe'), findsOneWidget);
    await tester.tap(find.byTooltip('Optionen für Lerngruppe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raum löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('Lerngruppe'), findsNothing);
  });
  testWidgets('send, edit, and delete a message through the UI', (
    tester,
  ) async {
    await start(tester);
    await revealRoom(tester, 'Ideen für morgen');
    await tester.tap(find.text('Ideen für morgen'));
    await tester.pumpAndSettle();
    expect(find.text('Mach den Anfang.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Ein guter Anfang');
    await tester.tap(find.byTooltip('Nachricht senden'));
    await tester.pumpAndSettle();
    expect(find.text('Ein guter Anfang'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );
    await tester.tap(find.byTooltip('Nachrichtenoptionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bearbeiten'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      'Eine bessere Idee',
    );
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.text('Eine bessere Idee'), findsOneWidget);
    await tester.tap(find.byTooltip('Nachrichtenoptionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nachricht löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('Mach den Anfang.'), findsOneWidget);
  });
  testWidgets('a failed send retains the draft and shows the error', (
    tester,
  ) async {
    await start(tester, repository: FailingSendRepository());
    await revealRoom(tester, 'Ankommen & Austauschen');
    await tester.tap(find.text('Ankommen & Austauschen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Bitte behalten');
    await tester.tap(find.byTooltip('Nachricht senden'));
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      'Bitte behalten',
    );
  });
  testWidgets('empty room titles are rejected in the form', (tester) async {
    await start(tester);
    await tester.tap(find.text('Neuer Raum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.text('Raumname darf nicht leer sein.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
  testWidgets('search filters rooms without a server call', (tester) async {
    await start(tester);
    await tester.enterText(find.byType(TextField), 'Werkstatt');
    await tester.pump();
    await revealRoom(tester, 'Flutter-Werkstatt');
    expect(find.text('Flutter-Werkstatt'), findsOneWidget);
    expect(find.text('Ankommen & Austauschen'), findsNothing);
  });
  testWidgets('small screens and enlarged text have no layout overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    expect(tester.takeException(), isNull);
    await revealRoom(tester, 'Ankommen & Austauschen');
    await tester.tap(find.text('Ankommen & Austauschen'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
