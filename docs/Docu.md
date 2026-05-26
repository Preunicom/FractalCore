# FractalCore

## Zuständigkeiten

Das Projekt FractalCore wurde von Thomas Schiergl und Markus Remy im Rahmen der Veranstaltung Ausgewählte Projekte der Informatik an der OTH Regensburg selbstständig umgsetzt.
Die Arbeitsaufteilung wurde wie folgt gewählt:
- Systementwurf : Markus Remy und Thomas Schiergl
- Projektstruktur + CI: Markus Remy
- Konfigurationsmodul: Thomas Schiergl
- Initialwerterzeugung: Markus Remy
- Mengenberechnung: Markus Remy
- Farbcodierung: Thomas Schiergl
- Anzeige: Thomas Schiergl
- Systemintegration: Thomas Schiergl und Markus Remy

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

_@author: Markus Remy_

## 0. Gesamtsystem

Um den verschiedenen Taktdomainen entsprechende Takt- und Resetsignale zur Verfügung zu stellen werden zwei Clocking Wizard IPs verwendet.
Der erste stellt allen Taktdomainen außer VGA das Taktsignal zur Verfügung.
Da der MMCM des ersten Clocking Wizards nicht parallel zu den anderen Taktsignalen auch 25,175 MHz erzuegen kann, wurde für den VGA Pixeltakt ein eigener Clocking Wizard mit MMCM verwendet.
Dieser erzeugt zwar auch keine 25,175 MHz, aber er liegt nur <0,01 MHz daneben, was ausreichend genau ist.
Als Resetsignale wird das locked signal der Clocking Wizards verwendet.
Da dieses nicht synchron in den Taktdomains sein muss, wird es mit zwei FlipFlops auf die jeweilige Taktdomaine synchronisiert um Metastabilität zu vermeiden.
Außerdem werden die beiden Taktdomainen für den Microblaze und die AXI Lite Verbindungen als ein SoC Signal vom Clocking Wizard erzeugt um die Komplexität des Systems möglichst gering zu halten.

_@author: Markus Remy_

## 1. MicroBlaze

## 2. UART Schnittstelle

## 3. Initialwertkoponente

Um ein animiertes Bild zu erzeugen werden nach einer ausgewählten Strategie Startwerte auf die Pixel verteilt.
Dafür werden z_0 und c Werte festgelegt.
Je nach Modus erfüllen diese unterschiedliche Eigenschaften.
Die Modi sowie die zughörigen Einstellungen können via AXI Lite konfiguriert werden.
Die genaueren Beschreibungen der dafür notwendigen Register sind in der entsprechenden [Registerbeschreibung](./Registerbeschreibungen/Initialwerterzeugung/) genauer beschrieben.

_@author: Markus Remy_

### 3.1 Julia Modus (0X)

Der Julia Modus wird mit den Steuerbits ``0X`` ausgewählt.
Für die Visualisierung wird die Julia Menge verwendet.
Dabei entspricht der Startwert für z_0 der Pixelkoordiante.
C wird pro Frame dem gleichen Wert zugewiesen und entpsricht einem Punkt, der für die Animation mit einer gewählten Strategie verschoben wird.
Zusätzlich wird, falls aktiviert, in der linken unteren Ecke eine Minimap angezeigt werden, in der markiert ist, wo sich das c derzeit befindet.

_@author: Markus Remy_

#### 3.1.1 Diamond Modus (00)

Im Diamond Modus wird das c im Koordinatensystem mit dem reelen Anteil als X-Achse und dem imaginären Anteil als Y-Achse in einer Rautenform verschoben.
Dabei kann die Breite und Höhe eingestellt werden.
Wenn die Breite ungleich der Höhe ist, ist die Raute nicht mehr gleichförmig, sondern die Seite wird im 45° Winkel abgefahren bis die Zielachse des kleineren Wertes erreicht ist.
Dann nähert sich der Wert auf der Achse dem Ziel an.

_@author: Markus Remy_

#### 3.1.2 LFSR Modus (01)

Im LFSR Modus wird das Ziel der aktuellen Bewegung anhand eines 18 Bit LFSR bestimmt.
Dieses kann umfänglich konfiguriert werden.
Die Schiebebewegung erfolgt dabei in Richtung MSB.
Bei entsprechender Konfiguration lassen sich so 262143 Pseudo Zufallswerte pro LFSR erreichen.
Jede Koordinatenachse hat dabei ein eigenes LFSR.
Wenn der Zielwert eines der LFSR erreicht ist, wechselt dieses zum nächsten Ziel. 
Das andere bleibt unverändert bis der zugehörige Koordinatenanteil des c den Wert erreicht hat.
Die daraus resultierende Vielfalt an Bewegungsmuster ist somit sehr groß und führt zu keinen Wiederholungen von Mustern in absehbarer Zeit.

_@author: Markus Remy_

### 3.2 Mandelbrot Modus (1X)

Im Mandelbrot Modus wird statisch das Mandelbrot angezeigt.
Dabei erfolgt keine Animation und die Minimap ist nicht verfügbar.
Als Startwerte wird für z_0 der Wert 0 verwendet und für c die Pixelkoordinate.

_@author: Markus Remy_

### 3.3 Minimap

Um die Minimap umzusetzen müssen zwei Pixelbereiche hervorgehboben werden.
Zusätzlich muss das untere linke Eck als Startwerte Mandelbrot Startwerte bekommen.
Da die Koordinaten in diesem Fall nicht direkt als c Startwert verwendet werden können, muss der Bereich auf die Fläche des gesamten Bildschirms gemappt werden.
Andernfalls würde nur der linke untere Teil des Mandelbrotausschnitts angezeigt werden.

Um diesen Effekt zu erreichen wird der Minimap Bereich mit einem viermal höheren Koordiantenabstand berechnet.
Da der Bereich genau ein Viertel der Höhe und ein Viertel der Breite des Bereichs ausgibt entspricht das genau dem Bildbereich.

Um die beiden Pixelbereiche für das aktuelle c und das Ziel c hervorzuheben, muss der zugehörige Pixel bestimmt werden.
Dies wird mit einer Abstandsrechnung erreicht.
Da bekannt ist, wie groß der Koordinatenabstand zwischen zwei Pixel ist, wird für jeden Pixel während der Erzeugung geprüft ob er näher als der Halbe Abstand im reelen und imaginären von c oder dem c Zielwert entfernt ist.
Sollte das der Fall sein wird der Pixel abgespeichert und mit dem aktuellen Frameindex nach außen hin weitergegeben.

Diese Information wird dann direkt von der Anzeige verarbeitet und ein Overlay über die Daten erzeugt.

Da die Werte schneller bei der Anzeigeeinheit sind als die Berechnung der Iterationen für die Pixel, liegen die beiden Werte vor der Iterationsanzahl vor.
Das könnte zu Race Conditions führen.

Da der Wert jedoch pro Frameindex gespeichert wird, müsste der Wert Pixel von drei Bildern überholen um einen Einfluss auf das falsche ausgegebene Bid zu haben.
Das liegt daran, dass der Frameindex sich alle 4 Bilder wiederholt.
Es ist aber nicht möglich so viele Pixel gleichzeitig im System zu speichern.
Dementsprechend kann der Wert diese Pixelanzahl auch nicht überholen und damit können auch keine Race Conditions entstehen.

## 4. Berechnung

### 4.1 Dispatcher

Der Dispatcher verteilt eingehende Startwerte für die Berechnung auf die Cores.
Da aufgrund Einschränkungen in der Konfiguration die asynchronen FIFOs nicht direkt vor den Cores platziert werden konnten, muss er davor platziert werden.
Damit ist der Dispatcher in der Clock Domaine der Cores und muss entprechend hoch getaktet werden können.
Es wurden verschiedene Ansätze getestet um eine möglichst hohe Taktfrequenz zu erreichen.

_@author: Markus Remy_

#### Baumstruktur

Allen Ansätzen gemeinsam hatte die Binärbaum Struktur.
Dabei wird immer ein Datensatz an Eingangsdaten auf zwei Ausgänge verteilt.
Die Entscheidung welcher Ausgang verwendet wird hängt dabei von der Herangehensweise ab.
So ist das Problem einfach zu lösen aber dennoch skalierbar mit der Anzahl an Cores.
Dafür werden die einzelnen Dispatcher als Knoten in einem Binärbaum interpretiert mit den Cores als Blätter des Baums.

_@author: Markus Remy_

#### Trivialer Ansatz

Der triviale Ansatz ist das ganze ohne Pipelining umzusetzen.
Dabei werden die Steuersignale sowie die Daten in beide Richtungen kombinatorisch durchgereicht.
Dieser Ansatz erziehlt die gleichmäßigste Verteilung auf die Cores, da Cores die Daten benötigen noch im selben Takt die Daten erhalten.
Diese Geschwindigkeit und Flexibilität ermöglicht jedoch nur sehr niedrige Taktfrequenzen und ist damit nicht geeignet.

_@author: Markus Remy_

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

_@author: Markus Remy_

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

_@author: Markus Remy_

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

_@author: Markus Remy_

#### Async FIFO IP

Der AXI Stream Async FIFO führt das Reset Signal intern in die zweite Clock Domaine über wobei er es synchronisieren muss.
Dafür benötigt er einen ausreichend langen Reset Puls um nach dem Reset direkt wie erwartet zu funktionieren.

Das ist auf der Hardware irrelevant, da das Reset Signal in diesem Aufbau durch den Clocking Wizard erzeugt wird und damit lange genug anliegt.
In Testbenches muss es jedoch beachtet werden.

_@author: Markus Remy_

## 5. Arbiter

Der Arbiter führt die Ergebnisse der parallelen Cores wieder zusammen.
Dabei soll ein Paket anhand der Pixelposition priorisiert werden.
Für den Arbiter gilt das gleiche wie für den Dispatcher bezüglich der Einschränkungen durch die FIFO Konfiguration.
Auch hier wurden wie beim Dispatcher mehrere Herangehensweisen getestet.
Das Ergebnis ist sehr ähnlich, da die Auswirkungen von langen Pfaden aufgrund der Priorisierung noch stärker wirken als beim Dispatcher.

Es wurde ein Skid Buffer gewählt und eine Priorisierung anhand der Pixelposition.
Da es nur eine Priorisierung ist und die Ergebnisse unterschiedlich lange berechnet werden, gibt es keine Garantie auf eine korrekte Reihenfolge der Pixel.
Das nachfolgende System muss diese Einschränkung entsprechend beachten.

_@author: Markus Remy_

## 6. Farbcodierung

## 7. VGA