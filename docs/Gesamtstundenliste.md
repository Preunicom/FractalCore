# Überblick über die geleisteten Stunden

## Zeitübersicht

| Entwickler | Aufgebrachte Zeit |
|------------|-------------------|
| Thomas Schiergl | 159 |
| Markus Remy | 219 |

## Implementierungsübersicht

| ID | Feature | Geplante Zeit [h] | Summe [h] | T [h] | M [h] | Zuständigkeit |
|---|---|---|---|---|---|---|
| 1 | **MicroBlaze** | (16) | 2 | - | 2 | Thomas |
| 1.1 | Instanzierung | 1 | - | - | - | Teil der Integration |
| 1.2 | Treibersteuerung | 10 | 1 | - | 1 | |
| 1.3 | Steuerungssoftware | 5 | 1 | - | 1 | |
| | | | | | | |
| 2 | **Serielle Schnittstelle** | (18) | - | - | - | Teil der Integration |
| 2.1 | UART IP instanziieren | 0,5 | - | - | - | |
| 2.2 | IP an Microblaze anbinden | 0,5 | - | - | - | |
| 2.3 | Menüführung | 5 | - | - | - | |
| 2.4 | Eingabeverarbeitung | 10 | - | - | - | |
| 2.5 | Fehlerbehandlung | 2 | - | - | - | |
| | | | | | | |
| 3 | **Initialwerterzeugung** | (52) | (45) | - | (45) | Markus |
| 3.1 | Bildschirmkoordinatenmapping | 12 | 9 | - | 9 | |
| 3.2 | _Animationssteuerung_ | (40) | (36) | - | (36) | |
| 3.2.1 | _Implementierung_ | (30) | (14) | - | (14) | |
| 3.2.1.1 | AXIL | 10 | 5 | - | 5 | |
| 3.2.1.2 | RTL | 20 | 9 | - | 9 | |
| 3.2.2 | _Tests_ | (10) | (22) | - | (22) | |
| 3.2.2.1 | AXIL | 5 | 3 | - | 3 | |
| 3.2.2.2 | RTL | 5 | 19 | - | 19 | |
| | | | | | | |
| 4 | **Mengenberechnung** | (65) | (39) | - | (39) | Markus |
| 4.1 | Dispatcher | 10 | 5 | - | 5 | |
| 4.2 | _Festkommaberechnung_ | (50) | (34) | - | (34) | |
| 4.2.1 | Implementierung | 20 | 6 | - | 6 | |
| 4.2.2 | Optimierung | 25 | 17 | - | 17 | |
| 4.2.3 | Tests | 5 | 11 | - | 11 | |
| 4.3 | Ergebnismeldung | 5 | - | - | - | Teil von 4.2.1 |
| | | | | | | |
| 5 | Ergebnisarbitrierung | 20 | 7 | - | 7 | Markus |
| | | | | | | |
| 6 | **Farbcodierung** | (15) | 97 | 97 | - | Thomas |
| 6.1 | Farbmapping | 8 | + | + | - | |
| 6.2 | Farbschemata | 7 | + | + | - | |
| | | | | | | |
| 7 | **VGA** | (70) | 53 | 53 | - | Thomas |
| 7.1 | _Framebuffer_ | (35) | + | + | - | |
| 7.1.1 | Schreib-/Lesezugriff | 15 | + | + | - | |
| 7.1.2 | Zugriffssynchronisation | 20 | + | + | - | |
| 7.2 | _VGA_ | (35) | + | + | - | |
| 7.2.1 | Pixelclock | 5 | + | + | - | |
| 7.2.2 | Framebufferanbindung | 10 | + | + | - | |
| 7.3 | Bildformaterzeugung | 20 | + | + | - | |
| | | | | | | |
| 8 | **Systementwurf** | 15 | 22 | 8 | 14 | Thomas + Markus |
| | | | | | | |
| 9 | **Systemintegration** | 20 | 30 | 1 | 29 | Thomas + Markus |
| | | | | | | |
| 10 | **Clock Domain Crossing** | 20 | 4 | - | 4 | Thomas + Markus |
| | | | | | | |
| Z1 | **Zusatzfeature: Portierung auf Arty Z7-20 mit HDMI** | 0 | 79 | - | 79 | Markus |

### Erklärung zur Implementierungsübersicht

- Ein + in einer Zelle bedeutet, dass diese Zelle nur aggreggiert angegeben wurde.
- Ein - bedeutet es wurde kein Aufwand dafür aufgewandt.
- Geklammerte Werte sind bereits in Einzelpositionen angegeben und nur zur Übersicht aufsummiert.
- Die Zuständigkeiten sind die urspünglich angegebenen.
Die Implemnetierung kann abweichen, wenn es sich zeitlich anders ausging.