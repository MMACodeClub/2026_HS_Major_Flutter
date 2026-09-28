# Warum diese Struktur?

Der Einstieg in den Folien sammelt viel Logik in einem `State`-Objekt. Das ist zum
Erklären praktisch. Diese Referenzlösung verteilt die Verantwortung so, dass
HTTP-Verhalten und UI-Zustand unabhängig von Widgets getestet werden können.

## Verantwortlichkeiten

| Baustein | Zuständig für | Kennt nicht |
| --- | --- | --- |
| Screen/Widget | Darstellung, Dialoge, Navigation, Text-Controller | HTTP und JSON |
| ViewModel | Laden, Speichern, Listen, Fehler und laufende Aktionen | BuildContext und Widgets |
| Repository | Operationen mit Räumen und Nachrichten | Darstellung |
| API-Client | HTTP, Statuscodes, Zeitlimit, JSON | UI-Zustand |
| Modelle | Gültige, unveränderliche Daten | HTTP und Widgets |

Die Aufteilung orientiert sich an der offiziellen
[Flutter-Architekturempfehlung](https://docs.flutter.dev/app-architecture/recommendations).
Die konkrete Umsetzung ist für eine kleine Lehr-App zugeschnitten:
Konstruktoren übernehmen die Abhängigkeitsübergabe, `ChangeNotifier` die
Zustandsbenachrichtigung. Weitere Pakete können später ergänzt werden, wenn
beispielsweise Deep Links, sehr viele Features oder komplexe Zustandsflüsse
sie rechtfertigen.

## Lebensdauer

`ChatApp` besitzt das Repository und schliesst dessen HTTP-Client beim Dispose.
Jeder Screen besitzt sein ViewModel und gibt es beim Verlassen frei.
Text- und Scroll-Controller gehören ebenfalls dem jeweiligen Screen.

Nach einer asynchronen Operation aktualisiert ein bereits freigegebenes
ViewModel weder Daten noch Listener. Widgets prüfen `mounted`, wenn sie nach
Dialogen oder Speichervorgängen noch Context oder Controller benötigen.
Ein abgeschickter HTTP-Aufruf wird durch das Verlassen eines Screens nicht
rückgängig gemacht; das Ergebnis kann serverseitig weiterhin eintreffen.

## Gleichzeitigkeit und Schreibvorgänge

Pro ViewModel läuft höchstens eine Lade- oder Schreiboperation. Die Oberfläche
deaktiviert passende Aktionen; die ViewModel-Prüfung verhindert zusätzlich,
dass mehrere schnelle Aufrufe denselben Schreibvorgang starten.

Nach erfolgreichem Schreiben lädt das ViewModel die Liste erneut. Scheitert nur
dieses Neuladen, bleibt die Schreiboperation erfolgreich. Die UI leert dann den
bereits gesendeten Entwurf und meldet, dass die Ansicht erneut geladen werden
muss. So verleitet ein fehlgeschlagener Refresh nicht zu einem doppelten POST.
Vorhandene Listendaten bleiben bei einem Fehler sichtbar.

Anfragen werden nicht automatisch wiederholt. Insbesondere POST darf ohne
serverseitige Idempotenz nicht blind erneut gesendet werden. Ein Timeout kann
bedeuten, dass die Antwort fehlt, obwohl der Server bereits gespeichert hat.
In diesem Fall zuerst aktualisieren. Das Zeitlimit umfasst Header und Body;
`Future.timeout` allein garantiert keinen Abbruch der Netzwerkverbindung.

## Was absichtlich klein bleibt

- Zwei Screens verwenden `Navigator` und keine komplexe Routing-Konfiguration.
- Kein zusätzlicher Service-Locator oder globale Repository-Singletons.
- Ein gemeinsames `ListViewModel` hält Fehler- und Lebenszykluslogik konsistent.
- Manuell geschriebene, kleine Modelle benötigen keine Codegenerierung.
- Keine automatische Abfrage im Hintergrund und keine erfundene Online-Anzeige.
- Nachrichten werden chronologisch sortiert und über stabile IDs adressiert.
- Anzeigenamen entscheiden nicht darüber, wem eine Nachricht gehört.

Eine typische nächste Ausbaustufe ist eine echte Session mit serverseitig
verifizierter Benutzer-ID und entsprechenden Berechtigungen. UI-Menüs allein
sind keine Autorisierung.

## Tests lesen

- `domain_test.dart`: Konfiguration, Pflichtfelder, Datentypen und Eingaben.
- `api_repository_test.dart`: Methoden, URLs, JSON, Statuscodes und Fehler.
- `demo_repository_test.dart`: vollständige CRUD-Abläufe ohne Server.
- `view_model_test.dart`: Lebenszyklus, Konkurrenz und Teilfehler.
- `app_test.dart`: Bedienung über echte Widgets und Dialoge.
