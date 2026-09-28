# Mitmachen

1. Repository forken oder einen eigenen Feature-Branch anlegen.
2. Eine kleine, nachvollziehbare Änderung umsetzen.
3. Passende Unit- oder Widget-Tests ergänzen.
4. Formatierung, Analyse und Tests ausführen:

```sh
dart format lib test
flutter analyze
flutter test
```

5. Einen Pull Request mit Problem, Änderung und Prüfung eröffnen.

Codebezeichner sind Englisch, Oberfläche und Lernunterlagen Deutsch.
Widgets enthalten Darstellung, Dialoge und Navigation; Datenzugriff gehört
hinter `ChatRepository`. Keine echten HTTP-Aufrufe in automatisierten Tests.

Bitte keine Zugangsdaten, privaten Nachrichten, IDE-Caches, Signaturschlüssel
oder lokalen Konfigurationsdateien einchecken. Die MIT-Lizenz gilt auch für
Beiträge zu diesem Lehrprojekt.
