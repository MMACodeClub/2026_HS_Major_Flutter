# API-Vertrag der Kurs-App

Basisadresse: konfigurierbar über `API_BASE_URL`, für den Kurs etwa `https://mmp.li`.
Die folgenden Pfade werden relativ zur Basisadresse angehängt.

| Methode | Pfad | JSON-Body | Akzeptierter Erfolg |
| --- | --- | --- | --- |
| GET | `/chats` | – | 200, Liste von Räumen |
| POST | `/chats` | `{"roomId":"Flutter"}` | 200 oder 201 |
| PUT | `/chats/{id}` | `{"roomId":"Neuer Name"}` | 200 oder 204 |
| DELETE | `/chats/{id}` | – | 200 oder 204 |
| GET | `/chats/{id}/messages` | – | 200, Liste von Nachrichten |
| POST | `/chats/{id}/messages` | `{"content":"Hoi!"}` | 200 oder 201 |
| PUT | `/chats/{id}/messages/{messageId}` | `{"content":"Geändert"}` | 200 oder 204 |
| DELETE | `/chats/{id}/messages/{messageId}` | – | 200 oder 204 |

## Beispielantworten

Raumliste:

```json
[{"_id":"room-1","roomId":"Flutter-Werkstatt","__v":0}]
```

Nachrichtenliste:

```json
[{
  "_id":"message-1",
  "randomName":"Ada",
  "content":"Hoi zäme!",
  "timestamp":"2026-09-28T10:00:00.000Z"
}]
```

Das Domainmodell nennt den Raumnamen `title` und den Anzeigenamen `author`.
`__v` wird für diese UI nicht gebraucht. Technische IDs, Titel und Pflichtfelder
werden validiert; fehlende IDs werden nicht still durch leere Strings ersetzt.
Unbekannte zusätzliche Felder werden ignoriert.

Die Antwort einer Schreiboperation wird nicht als Modell interpretiert;
stattdessen wird die betroffene Liste neu geladen. So sind auch leere
204-Antworten zulässig. Die App zeigt Serverfehler verständlich an und gibt
keine rohen Serverantworten an die UI weiter.

## Grenzen und Prüfung

Der Vertrag basiert auf der Kursvorlage. Beim lesenden Check am 28.09.2026
lieferte `GET /chats` HTTP 200 mit den erwarteten Raumfeldern. Schreib- und
Löschoperationen auf dem gemeinsamen Kursserver wurden bei der Erstellung
nicht ausgeführt. Die gesamte Clientlogik ist mit Mock-Antworten getestet;
das ist kein Nachweis der aktuellen serverseitigen Schreibberechtigungen.

Für den Webbetrieb muss der Server CORS korrekt unterstützen, einschliesslich
Preflight für JSON-POST, PUT und DELETE. Android hat die Internet-Berechtigung,
macOS das Netzwerk-Client-Entitlement bereits in den Projektdateien.

Die Beispiel-API liefert keine verlässliche Benutzeridentität für die App.
Das Projekt setzt keine Anmeldung oder Eigentumsrechte voraus. Ein öffentlich
betriebener eigener Backend-Dienst muss Authentifizierung, Autorisierung,
Eingabeprüfung und Missbrauchsschutz selbst umsetzen.
