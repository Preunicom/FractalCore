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
- Dia VGA Auflösung beträgt 640x480 Pixel und damit werden 10 (horizontal) bzw. 9 (vertikal) Bits benötigt um die Pixel zu numerieren
- Um eine Priorisierung bei der Arbitrierung auf Basis des Pixels sowie die Zuordnung im Framebuffer zu gewährleisten wird das Frame zum Pixel mit 2 Bit übertragen (=> Frame mod 4).
2 Bit deshalb, um bei der Arbitrierung zu entscheiden welcher Frame weiter in der Zukunft liegt falls zwei Pixel in verschiedenen Frames liegen.
- Da der Pmod VGA 12 Bit Farben unterstützt wurden die Bitbreiten der Farben entsprechend gewält.
- Um die langsamen Folgenberechnungen schneller zu berechnen sowie das VGA Timing einzuhalten werden verschiedene Clock Domainen verwendet.
- Die Abbruchbedingung liegt bei maximal 100 Iterationen.
Es wurden dennoch 8 Bit Datenbreite für die Anzahl an Takte bis zur konvergenz gewählt um die maximale Anzahl an Iterationen gegebenenfalls einfach erhöhen zu können, falls die Farbgebung bei 100 Iterationen nicht zufriedenstellend sein sollte.

## 0. Gesamtsystem

Um den verschiedenen Taktdomainen entsprechende Takt- und Resetsignale zur Verfügung zu stellen werden zwei Clocking Wizard IPs verwendet.
Der erste stellt allen Taktdomainen außer VGA das Taktsignal zur Verfügung.
Da der MMCM des ersten Clocking Wizards nicht parallel zu den anderen Taktsignalen auch 25,175 MHz erzuegen kann, wurde für den VGA Pixeltakt ein eigener Clocking Wizard mit MMCM verwendet.
Dieser erzeugt zwar auch keine 25,175 MHz, aber er liegt nur <0,01 MHz daneben, was ausreichend genau ist.
Als Resetsignale wird das locked signal der Clocking Wizards verwendet.
Da dieses nicht synchron in den Taktdomains sein muss, wird es mit zwei FlipFlops auf die jeweilige Taktdomaine synchronisiert um Metastabilität zu vermeiden.
Außerdem werden die beiden Taktdomainen für den Microblaze und die AXI Lite Verbindungen als ein SoC Signal vom Clocking Wizard erzeugt um die Komplexität des Systems möglichst gering zu halten.

## 1. MicroBlaze

## 2. UART Schnittstelle

## 3. Initialwertkoponente

## 4. Berechnung

### 4.1 Dispatcher

Der Dispatcher verteilt eingehende Startwerte für die Berechnung auf die Cores.
Da aufgrund Einschränkungen in der Konfiguration die asynchronen FIFOs nicht direkt vor den Cores platziert werden konnten, muss er davor platziert werden.
Damit ist der Dispatcher in der Clock Domaine der Cores und muss entprechend hoch getaktet werden können.
Es wurden verschiedene Ansätze getestet um eine möglichst hohe Taktfrequenz zu erreichen.

#### Baumstruktur

Allen Ansätzen gemeinsam hatte die Binärbaum Struktur.
Dabei wird immer ein Datensatz an Eingangsdaten auf zwei Ausgänge verteilt.
Die Entscheidung welcher Ausgang verwendet wird hängt dabei von der Herangehensweise ab.
So ist das Problem einfach zu lösen aber dennoch skalierbar mit der Anzahl an Cores.
Dafür werden die einzelnen Dispatcher als Knoten in einem Binärbaum interpretiert mit den Cores als Blätter des Baums.

#### Trivialer Ansatz

Der triviale Ansatz ist das ganze ohne Pipelining umzusetzen.
Dabei werden die Steuersignale sowie die Daten in beide Richtungen kombinatorisch durchgereicht.
Dieser Ansatz erziehlt die gleichmäßigste Verteilung auf die Cores, da Cores die Daten benötigen noch im selben Takt die Daten erhalten.
Diese Geschwindigkeit und Flexibilität ermöglicht jedoch nur sehr niedrige Taktfrequenzen und ist damit nicht geeignet.

#### Gepipelinter Datenpfad

Die nächstliegende Möglichkeit ist das synchronisieren der Signale um so eine höhere Taktrate zu erzielen.
Jedoch ist das ready signal hierbei weiterhin kombinatorisch, da es in der Pipeline in die entgegengesetzte Richtung führt.
Das erschwert das synchronisieren dieses Signals.
Der Pfad des ready signals beinhaltet nur einfache Logik, aber da es dennoch in jeder Ebene des Baums durch eine Look-Up-Table führt skaliert dieser Ansatz nicht gut für größere Anzahlen an Cores.
Außerdem wandern so angefragt Daten mit jedem Takt nur eine Ebene durch den Baum.
Dementsprechend muss ein Core die Höhe des Baums in Takten auf die Daten warten.
Zusätzlich muss Logik implementiert werden um das ready Signal des Cores zu erhalten, da ein Slot im Core nur jeden dritten Takt Daten anfragt.
Falls ein Core mehrere freie Slots hat, muss die Anzahl an freien Slots mit der Höhe des Baums multipliziert werden um die Wartetakte z uermitteln, da erst nach dem Empfangen der Daten am Core die nächste Anfrage erkannt wird.

Zusammengefasst eignet sich diese Möglichkeit nicht aufgrund ihrer Komplexität sowie auf der weiterhin niedrigen Taktfrequenz.

#### Skid Buffer

Um das ready signal auch mit in die Pipeline aufzunehmen, und somit kürzere Pfade zu haben, wird ein Skid Buffer verwendet.
Dieser geht davon aus, dass im nächsten Takt einer der beiden nachfolgenden Partner bereit ist und empfängt Daten.
Sollte kein Partner bereit sein, nimmt er die empfangenen Daten in den inneren Buffer auf.
Er ist dann solange nicht mehr bereit, bis der innere Puffer wieder an einen der Ausgänge weitergegeben werden konnte, da einer der Partner Daten gelesen hat.
Das hat den Vorteil, dass die kombinatorischen Kontroll- und Datenpfade durchbrochen werden und höhere Taktfrequenzen möglich sind.
Dafür ist in jeder Stufe ein Wert gespeichert und die Daten müssen unter Umständen im Baum warten während in der anderen Baumhälfte ein Core leerläuft.
Das ist nicht optimal, jedoch vertretbar, da ein Wert aufgrund der Baumstruktur nicht nur einen Core nach sich hat, der ihn entgegennehmen kann, sondern mehrere.
Er hat in jeder Stufe 2^(n-x) mögliche Cores, mit n der Höhe des Baums und x der nullindizierten Ebene des Baums.
Um diese Eigenschaft optimal auszunutzen verteilt der Dispatcher die Werte falls beide Kinder bereit sind an das Kind, das nicht den letzten Wert erhalten hat.
So verteilt sich die Last möglichst gleichmäßig im Baum und damit auf die Cores.

Damit ist diese Lösung die beste der getesteten Varianten und erlaubt eine Taktfrequenz von über 100 MHz.

### 4.2 Core

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
Dabei soll ein Paket anhand der Pixelposition priorisiert werden.
Für den Arbiter gilt das gleiche wie für den Dispatcher bezüglich der Einschränkungen durch die FIFO Konfiguration.
Auch hier wurden wie beim Dispatcher mehrere Herangehensweisen getestet.
Das Ergebnis ist sehr ähnlich, da die Auswirkungen von langen Pfaden aufgrund der Priorisierung noch stärker wirken als beim Dispatcher.

Es wurde ein Skid Buffer gewählt und eine Priorisierung anhand der Pixelposition.
Da es nur eine Priorisierung ist und die Ergebnisse unterschiedlich lange berechnet werden, gibt es keine Garantie auf eine korrekte Reihenfolge der Pixel.
Das nachfolgende System muss diese Einschränkung entsprechend beachten.

## 6. Farbcodierung

Die Farbcodierung wandelt die vom Framebuffer bereitgestellten Iterationszahlen in RGB-Farbwerte um. Dadurch wird die eigentliche Fraktalstruktur für den Benutzer sichtbar gemacht.
Da die Berechnung und die Darstellung voneinander getrennt sind, kann das verwendete Farbschema geändert werden, ohne dass die Fraktaldaten neu berechnet werden müssen. Der Framebuffer speichert nur die Anzahl der Iterationen bis zur Divergenz und keine fertigen Farbwerte.

### 6.1 Trennung von Berechnung und Darstellung

Die Cores berechnen für jeden Pixel lediglich die Anzahl der Iterationen bis zum Erreichen der Abbruchbedingung. Dieser Wert wird als 8-Bit-Zahl gespeichert.

Die Umwandlung in eine Farbe erfolgt erst bei der Ausgabe. Dadurch ergeben sich mehrere Vorteile:

- Der Speicherbedarf des Framebuffers wird reduziert.
- Das Farbschema kann jederzeit geändert werden.
- Für unterschiedliche Darstellungen müssen keine neuen Fraktaldaten berechnet werden.

### 6.2 Farbschemata

Die Farbcodierung unterstützt mehrere Farbschemata, zwischen denen während der Laufzeit gewechselt werden kann.

Mögliche Schemata sind:

- Graustufen
- Schwarz-Weiß
- Blau → Grün → Gelb → Rot
- Feuerfarbschema

Die Auswahl des Farbschemas erfolgt über ein separates Steuersignal.
Dadurch können unterschiedliche Darstellungen derselben Fraktalmenge erzeugt werden, ohne die eigentliche Berechnung zu beeinflussen.

### 6.3 Behandlung konvergenter Punkte

Die Iterationsanzahl wird mit 8 Bit gespeichert. Obwohl aktuell maximal 100 Iterationen berechnet werden, erlaubt die gewählte Datenbreite eine spätere Erhöhung dieses Grenzwertes.
Erreicht ein Punkt die maximale Iterationsanzahl, ohne die Divergenzbedingung zu erfüllen, wird er als konvergent betrachtet.
Diese Punkte werden in der Regel mit einer festen Farbe dargestellt, beispielsweise Schwarz. Dadurch wird das Innere der Mandelbrotmenge klar vom äußeren Bereich abgegrenzt.

### 6.4 Ressourcenbedarf

Die Farbcodierung besteht ausschließlich aus kombinatorischer Logik und benötigt keine DSP-Blöcke.
Da lediglich Vergleiche und einfache Zuordnungen von Farbwerten durchgeführt werden, ist der Ressourcenverbrauch gering und die Komponente kann mit hohen Taktraten betrieben werden.

## 7. VGA

Die VGA-Komponente erzeugt die für den Pmod VGA benötigten Synchronisationssignale sowie die Ausgabe der Farbwerte.
Sie arbeitet unabhängig von der Berechnungslogik und liest die benötigten Pixeldaten aus dem Framebuffer.

### 7.1 VGA-Timing

Für die Bildausgabe wird der Standardmodus 640 × 480 @ 60 Hz verwendet.
Dieser Modus benötigt einen Pixeltakt von ungefähr 25,175 MHz.
Da dieser Takt nicht exakt durch die vorhandenen Clocking-Ressourcen erzeugt werden kann, wird ein sehr nahe liegender Takt verwendet.
Die Abweichung ist gering genug, um von VGA-Monitoren problemlos akzeptiert zu werden.

### 7.2 Erzeugung der Synchronisationssignale

Die VGA-Komponente erzeugt die horizontalen und vertikalen Synchronisationssignale durch zwei Zähler:

- Horizontalzähler
- Vertikalzähler

Der Horizontalzähler zählt die Pixel einer Zeile.
Nach Erreichen des Zeilenendes wird er zurückgesetzt und der Vertikalzähler erhöht.
Die Synchronisationssignale werden aus den aktuellen Zählerständen abgeleitet.

### 7.3 Sichtbarer Bildbereich

Nicht alle Zählerstände entsprechen sichtbaren Pixeln.

Neben dem eigentlichen Bildbereich existieren zusätzliche Zeitbereiche für:

- Front Porch
- Sync Pulse
- Back Porch

Nur während des sichtbaren Bereichs werden Farbwerte ausgegeben.
Außerhalb dieses Bereichs werden die Farbkanäle auf Null gesetzt.
Dadurch werden ausschließlich gültige Bilddaten an den Monitor übertragen.

### 7.4 Anbindung des Framebuffers

Die VGA-Komponente verwendet die aktuellen Pixelkoordinaten direkt als Leseadresse für den Framebuffer.
Damit ergibt sich eine kontinuierliche Rasterabtastung des Bildspeichers.

Für jedes sichtbare Pixel werden die folgenden Schritte ausgeführt:

1. Ermittlung der aktuellen Pixelkoordinate
2. Lesen des Iterationswertes aus dem Framebuffer
3. Umwandlung des Iterationswertes in einen RGB-Farbwert durch die Farbcodierung
4. Ausgabe der Farbe an den VGA-Port

Dadurch wird das vollständige Fraktalbild zyklisch mit der Bildwiederholrate aktualisiert.

### 7.5 Taktdomäne

Die VGA-Komponente arbeitet in einer eigenen Taktdomäne.
Dadurch ist die Bildausgabe unabhängig von der Berechnungsgeschwindigkeit der Fraktalberechnung.
Kurze Schwankungen oder Verzögerungen bei der Berechnung beeinflussen daher nicht das VGA-Timing.
Die Trennung der Taktdomänen vereinfacht die Einhaltung der Timing-Anforderungen des Systems und erhöht die Stabilität der Bildausgabe.

