# FractalCore

## Systementwurf und Schnittstellendefinition

Das System besteht aus folgenden Komponenten:  
![Komponentendiagramm](./pictures/DAPI_Projektvorschlag.drawio.svg)

Die Schnittstellen sind im folgenden genauer visualisiert:  
![Schnittstellen auf IP Ebene](./pictures/FractalCore_Schnittstellendefinition.drawio.svg)

Dabei sind ein paar Designentscheidungen gesondert aufzuführen:
- Das gewählte interne Kommunikationsprotokoll basiert auf AXI Stream, sendet aber mehrere Datenwörter mit verschiedenen Breiten parallel basierend auf dem gleichen Ready/Valid Handshake.
- Es werden 18 Bit Festkommazahlen für Real- und Imaginärteil der Zahlen verwendet, da die DSP des Arty A7 Multiplikationen mit maximal 25x18 Bit durchführen können.
- Die Festkommazahlen sind signed und im Format 3.15 gewählt.
Damit sind Werte im Bereich [-8,8[ möglich, was die relevanten Stellen abdeckt und dennoch eine hohe Präzision ermöglicht.
- Dia VGA Auflösung beträgt 640x480 Pixel und damit werden 10 (horizontal) bzw. 9 (vertical) Bit benötigt um die Pixel zu numerieren
- Um eine Priorisierung bei der Arbitrierung auf Basis des Pixels sowie die Zuordnung im Framebuffer zu gewährleisten wird das Frame zum Pixel mit 2 Bit übertragen (=> Frame mod 4).
2 Bit deshalb, um bei der Arbitrierung zu entscheiden welcher Frame weiter in der Zukunft liegt falls zwei Pixel in verschiedenen Frames liegen.
- Da der Pmod VGA 12 Bit Farben unterstützt wurden die Bitbreiten der Farben entsprechend gewält.
- Um die langsamen Folgenberechnungen schneller zu berechnen sowie das VGA Timing einzuhalten werden verschiedene Clock Domainen verwendet.
- Die Abbruchbedingung liegt bei maximal 255 Takten.
Abhängig von der Geschwindigkeit werden ggf. weniger verwendet.

## 4. Berechnung

### 4.1 Core

#### Rundungsfehler

Der Core berechnet die Mandelbrot Folge und gibt die Anzahl an Takten bis zur Divergenz bzw. ein Flag für Konvergenz aus.
Dabei werden Festkommazahlen im Format 3.15 verwendet um die DSP des FPGA möglichst effizient zu nutzen.

Bei der Berechnung der Mandelbrot Gleichung entstehen Ergebnisse mit Bitbreiten bis zu 39 Bit.
Diese müssen wieder auf die 18 Bit der 3.15 Bit Festkommazahlen gebracht werden um für die nächste Iteration als Startwert verwendet werden zu können.
Dabei wird sowohl der Ganzzahlanteil als auch der Nachkommanateil um einige Bits gekürzt, was zu Ungenauigkeiten in der Berechnung führt.
Diese Abweichung beeinflusst das Ergebnis besonders bei Folgen mit vielen Iterationen bis zum Abbruch.
Dementsprechend kann und wird die Iterationsanzahl teilweise vom Idealwert abweichen.
Eine mögliche Alternative wären Gleitkommazahlen, die aber auf dem FPGA sehr aufwendig umzusetzen sind und zusätzlich langsamer wären, da die DSPs keine Gleitkommaoperationen unterstützen.

Diese Rechenungenauigkeit sollte dich jedoch nicht so stark auf die Visualisierung auswirken, da nur Pixel am Rand der Menge betroffen sind.
Dort sind die Farben zwar etwas im Farbschema verschoben, was aber bei einem Farbschema mit Farbverlauf nicht so stark ins Gewicht fallen sollte.

#### Async FIFO IP

Der AXI Stream Async FIFO führt das Reset Signal intern in die zweite Clock Domaine über wobei er es synchronisieren muss.
Dafür benötigt er einen ausreichend langen Reset Puls um nach dem Reset direkt wie erwartet zu funktionieren.

Das ist auf der Hardware irrelevant, da das Reset Signal in diesem Aufbau durch den Clocking Wizard erzeugt wird und damit lange genug anliegt.
In Testbenches muss es jedoch beachtet werden.

## 5. Arbiter

Der Arbiter führt die Ergebnisse der parallelen Cores wieder zusammen.
Ursprünglich war geplant das anhand der Pixelposition für jedes Paket zu priorisieren.
Allerdings kostet diese Logik zu viel Zeit um sie auf der Taktfreuquenz der Cores umzusetzen.
Um zusätzlich Ressourcen zu sparen und aufgrund Einschränkungen in der Konfiguration der asynchronen FIFO IPs ist es auch nicht wie anfangs geplant möglich die Logik in der Ausgangstaktfrequenz umzusetzen.

Anstatt anhand von Prioritäten vorzugehen ist der alternativ gewählte Ansatz ein Round Robin Prinzip.
Jeder Arbiter merkt sich welcher der beiden Master zuletzt gesendet hat.
Wenn beide senden wollen wird der Master bevorzugt behandelt, der nicht zuletzt gesendet hat.
Somit ist Starvation ausgeschlossen.
So wird das Bild im Framebuffer zwar nicht strikt der Reihenfolge von links oben nach rechts unten aufgebaut, aber der Durchsatz bleibt gleich.
Aufgrund des Framebuffers und der Tatsache, dass es kein Starvation gibt, ist die Abweichung in der Reihenfolge kein Problem, da genug zeitlicher Spielraum vorhanden ist mit einem Frame Vorsprung vor der VGA Ausgabe.