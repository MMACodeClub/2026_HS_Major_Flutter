# Von den Folien zum eigenen Projekt

Die Aufgaben lassen sich einzeln als kleine Pull Requests bearbeiten.
Die vorhandene App ist eine Referenzlösung; probiert Änderungen gezielt aus
und erklärt im Review, warum sie funktionieren.

## 1. Widgets, State und Hot Reload

1. App im Demomodus starten und einen Raum öffnen.
2. Die Startfarbe in `ui/core/app_theme.dart` ändern.
3. Hot Reload auslösen. Was bleibt erhalten? Was passiert bei Hot Restart?
4. In `rooms_screen.dart` zwischen UI-Logik und Layout unterscheiden.

**Bezug zu den Folien:** `main`, `runApp`, Widget-Baum, `StatelessWidget`,
`StatefulWidget`, `setState` und Material 3.

## 2. Vom State zum ViewModel

1. `RoomsScreen`, `RoomsViewModel` und `ListViewModel` nebeneinander öffnen.
2. Den Weg eines Klicks auf «Neuer Raum» verfolgen.
3. Erklären, wer `notifyListeners` aufruft und wer darauf reagiert.
4. Den Test zu einer doppelten Schreibaktion ausführen und erklären.

**Bezug zu den Folien:** Lokaler State bleibt für Suche, Dialoge und Entwürfe
im Widget. Der asynchrone Datenzustand ist in ein testbares Objekt ausgelagert.
`ListenableBuilder` verbindet dieses Objekt mit der Oberfläche.

## 3. JSON und HTTP

1. Die Feldnamen des API-Vertrags mit `ChatRoom.fromJson` vergleichen.
2. Im HTTP-Test eine Antwort ohne `_id` liefern. Was passiert?
3. Eine 500-Antwort und einen Timeout simulieren.
4. Erst dann mit der Kurs-API einen eigenen Übungsraum verwenden.

**Bezug zu den Folien:** `Future`, `async`, `await`, JSON, Statuscodes und Fehler.

## 4. Lebenszyklus und Fehler

1. Den Test zu einer verspäteten Antwort nach `dispose` lesen.
2. Erklären, weshalb `mounted` nur im Widget verfügbar ist.
3. Den Unterschied zwischen fehlgeschlagenem Speichern und fehlgeschlagenem
   Neuladen nach erfolgreichem Speichern beschreiben.
4. Einen zusätzlichen Test für einen konkreten Fehlerfall ergänzen.

## 5. Kleine Erweiterungen

- Räume alphabetisch sortieren und einen Test dafür schreiben.
- Eine Zeichenanzeige für Raumnamen verbessern.
- Eine Nachricht per Tastenkürzel senden, ohne Zeilenumbrüche zu verlieren.
- Suchbegriffe im Raumtitel visuell hervorheben.
- Datumstrenner zwischen Nachrichten verschiedener Tage anzeigen.

## 6. Fortgeschrittene Erweiterungen

- Persistenz im Demomodus hinter derselben Repository-Schnittstelle ergänzen.
- Polling ohne überlappende Anfragen und mit sauberem Dispose implementieren.
- Einen eigenen Backend-Dienst mit Anmeldung und serverseitigen Rechten bauen.
- WebSockets einsetzen, sofern der eigene Server dies unterstützt.
- Deep Links für einzelne Räume mit einer Routing-Lösung ergänzen.

## Review-Fragen

- Funktioniert die Änderung auch mit leerer Liste und ungültigen Eingaben?
- Was sieht man bei einem Serverfehler?
- Was passiert, wenn man den Bildschirm während der Anfrage verlässt?
- Können doppelte Klicks doppelte Daten erzeugen?
- Sind Tests unabhängig vom öffentlichen Kursserver?
- Ist die Oberfläche per Tastatur und mit grösserer Schrift bedienbar?
