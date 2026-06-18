# FractalCore

## Zuständigkeiten

Das Projekt FractalCore wurde von Thomas Schiergl und Markus Remy im Rahmen der Veranstaltung Ausgewählte Projekte der Informatik an der OTH Regensburg selbstständig umgesetzt.
Die Arbeitsaufteilung wurde wie folgt gewählt:
- Systementwurf : Markus Remy und Thomas Schiergl
- Projektstruktur + CI: Markus Remy
- Konfigurationsmodul: Thomas Schiergl
- Initialwerterzeugung: Markus Remy
- Mengenberechnung: Markus Remy
- Farbcodierung: Thomas Schiergl
- Anzeige: Thomas Schiergl
- Systemintegration: Thomas Schiergl und Markus Remy

Als zusätzliches Feature wurde das Projekt auf den Arty Z7-20 portiert.
Dazu wurde das Konfigurationsmodul sowie Farbcodierung und Anzeige von Markus Remy neu entwickelt.
Damit ergibt sich für die Portierung auf das Arty Z7-20 folgende Arbeitsaufteilung:
- Systementwurf : Markus Remy und Thomas Schiergl
- Projektstruktur + CI: Markus Remy
- Konfigurationsmodul: Markus Remy
- Initialwerterzeugung: Markus Remy
- Mengenberechnung: Markus Remy
- Farbcodierung: Markus Remy
- Anzeige: Markus Remy
- Systemintegration: Markus Remy

Zusätzlich wurde auf dem Arty Z7 eine Minimap als Zusatzfeature hinzugefügt.
Diese ermöglicht ein besseres Verständnis der Julia Menge.
Die Minimap Daten werden auch auf dem Arty A7 erzeugt, jedoch unterstützt die Software sowie das Anzeigemodul dieses Zusatzfeature aus zeitlichen Gründen nicht.

_@author: Markus Remy_

## Systementwurf und Schnittstellendefinition

Das System besteht aus folgenden Komponenten:  
![Komponentendiagramm](./pictures/DAPI_Projektvorschlag.drawio.svg)

Die Farbcodierung und Anzeige sind dabei jedoch in einer Implementierungseinheit zusammengefasst, da sie stark voneinander abhängen.

Die Schnittstellen sind im folgenden genauer visualisiert:  
![Schnittstellen auf IP Ebene](./pictures/FractalCore_Schnittstellendefinition.drawio.svg)

Die Schnittstellenvisualisierung bezieht sich auf den Arty A7.
Die gestrichelte Linie der Minimap Daten wurde auf dem Arty A7 nicht implementiert, ist als weiteres Zusatzfeature jedoch als Ausblick umsetzbar.
Der Arty Z7 verwendet des weiteren einen DVI Encoder um das erzeugte VGA Signal weiterzuverarbeiten.

Ein paar Designentscheidungen sind gesondert aufzuführen:
- Das gewählte interne Kommunikationsprotokoll basiert auf AXI Stream, sendet aber mehrere Datenwörter mit verschiedenen Breiten parallel basierend auf dem gleichen Ready/Valid Handshake.
- Es werden 18 Bit Festkommazahlen für Real- und Imaginärteil der Zahlen verwendet, da die DSP des Arty A7 Multiplikationen mit maximal 25x18 Bit durchführen können.
- Die Festkommazahlen sind signed und im Format 3.15 gewählt.
Damit sind Werte im Bereich [-4,4[ möglich, was die relevanten Stellen abdeckt und dennoch eine hohe Präzision ermöglicht.
- Die VGA Auflösung beträgt 640x480 Pixel und damit werden 10 (horizontal) bzw. 9 (vertikal) Bits benötigt um die Pixel zu nummerieren
- Um eine Priorisierung bei der Arbitrierung auf Basis des Pixels sowie die Zuordnung im Framebuffer zu gewährleisten wird die Nummer des Frames zum Pixel mit 2 Bit übertragen (=> Frame Index mod 4).
2 Bit deshalb, um bei der Arbitrierung zu entscheiden welcher Frame weiter in der Zukunft liegt falls zwei Pixel in verschiedenen Frames liegen.
Andernfalls wäre nicht eindeutig definiert ob der Wechsel von Frame 0 zu Frame 1 oder von Frame 1 zu Frame 0 wäre.
- Da der Pmod VGA 12 Bit Farben unterstützt wurden die Bitbreiten der Farben entsprechend gewählt.
(In der Implementierung des HDMI Zusatzfeatures werden 8 Bit pro Farbe unterstützt)
- Um die langsamen Folgenberechnungen schneller zu berechnen sowie das VGA Timing einzuhalten werden verschiedene Clock Domainen verwendet. 
(In der Implementierung des Arty Z7 Zusatzfeatures wird die gesamte Logik bis auf den durch das Videoprotokoll festgelegten Anteil auf der schnellsten Clock Domain berechnet um möglichst wenig Übergänge zwischen Clock Domainen zu haben)
- Die Abbruchbedingung liegt bei maximal 100 Iterationen.
Es wurden dennoch 8 Bit Datenbreite für die Anzahl an Takte bis zur konvergenz gewählt um die maximale Anzahl an Iterationen gegebenenfalls einfach erhöhen zu können, falls die Farbgebung bei 100 Iterationen nicht zufriedenstellend sein sollte.

_@author: Markus Remy_

## 0. Gesamtsystem

Um den verschiedenen Taktdomainen entsprechende Takt- und Resetsignale zur Verfügung zu stellen wird ein Clocking Wizard IP verwendet.
Da der MMCM des Clocking Wizards nicht genau 25,175 MHz erzeugen kann, werden für den VGA Pixeltakt ca. 25 MHz verwendet.
Dieser liegt nur <0,2 MHz neben den laut Protokoll vorgeschriebenen 25.175 MHz, was für die meisten Bildschirme ausreichend genau ist.
Als Resetsignal wird das locked Signal der Clocking Wizards verwendet.
Da dieses nicht synchron in den Taktdomains sein muss, wird es mit zwei FlipFlops auf die jeweilige Taktdomaine synchronisiert um Metastabilität zu vermeiden und einen synchronen Reset zu ermöglichen.

_@author: Markus Remy_

## 1. MicroBlaze

TODO @Thomas

_@author: Thomas Schiergl_

## 2. UART Schnittstelle

TODO @Thomas

_@author: Thomas Schiergl_

## 3. Initialwertkomponente

Um ein animiertes Bild zu erzeugen werden nach einer ausgewählten Strategie Startwerte auf die Pixel verteilt.
Dafür werden z_0 und c Werte festgelegt.
Je nach Modus erfüllen diese unterschiedliche Eigenschaften.
Die Modi sowie die zughörigen Einstellungen können via AXI Lite konfiguriert werden.
Die genaueren Beschreibungen der dafür notwendigen Register sind in der entsprechenden [Registerbeschreibung](./Registerbeschreibungen/Initialwerterzeugung/) genauer beschrieben.

_@author: Markus Remy_

### 3.1 Julia Modus (0X)

Der Julia Modus wird mit den Steuerbits ``0X`` ausgewählt.
Für die Visualisierung wird die Julia Menge verwendet.
Dabei entspricht der Startwert für z_0 der Pixelkoordinate.
C wird pro Frame dem gleichen Wert zugewiesen und entspricht einem Punkt, der für die Animation mit einer gewählten Strategie verschoben wird.
Zusätzlich wird, falls aktiviert, in der linken unteren Ecke eine Minimap angezeigt werden, in der markiert ist, wo sich das c derzeit befindet.

_@author: Markus Remy_

#### 3.1.1 Diamond Modus (00)

Im Diamond Modus wird das c im Koordinatensystem mit dem reellen Anteil als X-Achse und dem imaginären Anteil als Y-Achse in einer Rautenform verschoben.
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

Um die Minimap umzusetzen müssen zwei Pixelbereiche hervorgehoben werden.
Zusätzlich muss das untere linke Eck als Startwerte Mandelbrot Startwerte bekommen.
Da die Koordinaten in diesem Fall nicht direkt als c Startwert verwendet werden können, muss der Bereich auf die Fläche des gesamten Bildschirms gemappt werden.
Andernfalls würde nur der linke untere Teil des Mandelbrotausschnitts angezeigt werden.

Um diesen Effekt zu erreichen wird der Minimap Bereich mit einem viermal höheren Koordinatenabstand berechnet.
Da der Bereich genau ein Viertel der Höhe und ein Viertel der Breite des Bereichs ausgibt entspricht das genau dem Bildbereich.

Um die beiden Pixelbereiche für das aktuelle c und das Ziel c hervorzuheben, muss der zugehörige Pixel bestimmt werden.
Dies wird mit einer Abstandsrechnung erreicht.
Da bekannt ist, wie groß der Koordinatenabstand zwischen zwei Pixel ist, wird für jeden Pixel während der Erzeugung geprüft, ob er näher als der halbe Abstand im reellen und imaginären von c oder dem c Zielwert entfernt ist.
Sollte das der Fall sein wird der Pixel abgespeichert und mit dem aktuellen Frameindex nach außen hin weitergegeben.

Diese Information wird dann direkt von der Anzeige verarbeitet und ein Overlay über die Daten erzeugt.

Da die Werte schneller bei der Anzeigeeinheit sind als die Berechnung der Iterationen für die Pixel, liegen die beiden Werte vor der Iterationsanzahl vor.
Das könnte zu Race Conditions führen.

Da der Wert jedoch pro Frameindex gespeichert wird, müsste der Wert Pixel von drei Bildern überholen um einen Einfluss auf das falsche ausgegebene Bild zu haben.
Das liegt daran, dass der Frameindex sich alle 4 Bilder wiederholt.
Es ist aber nicht möglich so viele Pixel gleichzeitig im System zu speichern.
Dementsprechend kann der Wert diese Pixelanzahl auch nicht überholen und damit können auch keine Race Conditions entstehen.

_Anmerkung_: Dieses Feature wird von der Initialwerterzeugung unterstützt, jedoch ist es nur auf dem Arty Z7 auch in der Anzeige implementiert.

_@author: Markus Remy_

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
Dieser Ansatz erzielt die gleichmäßigste Verteilung auf die Cores, da Cores die Daten benötigen noch im selben Takt die Daten erhalten.
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
Falls ein Core mehrere freie Slots hat, muss die Anzahl an freien Slots mit der Höhe des Baums multipliziert werden um die Wartetakte zu ermitteln, da erst nach dem Empfangen der Daten am Core die nächste Anfrage erkannt wird.

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

Diese Rechenungenauigkeit sollte sich jedoch nicht so stark auf die Visualisierung auswirken, da nur Pixel am Rand der Menge betroffen sind.
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

### 6.5 Entwurfsentscheidungen und Speicheroptimierung

Ursprünglich war vorgesehen, den Framebuffer nach der Farbcodierung zu platzieren und somit die bereits fertig berechneten RGB-Farbwerte zwischenzuspeichern.
Dabei hätte jeder Pixel direkt mit seinen 12 Bit Farbinformationen gespeichert werden müssen, da der Pmod VGA vier Bit pro Farbkanal verwendet.
Bei einer Auflösung von 640 × 480 Pixeln ergibt sich damit ein Speicherbedarf von:

```
640 × 480 × 12 Bit = 3 686 400 Bit
```

Dies entspricht ungefähr 450 KiB Speicher pro Bild.
Da auf dem FPGA nur eine begrenzte Menge an Block RAM zur Verfügung steht, erwies sich dieser Ansatz als ungeeignet.

Stattdessen wurde die Reihenfolge der Komponenten geändert:

```
Framebuffer → Farbcodierung → VGA
```

Dadurch speichert der Framebuffer lediglich die Anzahl der Iterationen bis zur Divergenz.

Mit einer Datenbreite von 9 Bit ergibt sich ein Speicherbedarf von:

```
640 × 480 × 9 Bit = 2 764 800 Bit
```

Dadurch reduziert sich der Speicherbedarf um ein Drittel, während gleichzeitig die Möglichkeit erhalten bleibt, das Farbschema zur Laufzeit zu ändern.
Die gewählte Architektur ist daher sowohl ressourcenschonender als auch flexibler als die ursprüngliche Lösung.

### 6.6 Unvollständige Sortierung der Pixel

Durch die parallele Berechnung der Fraktalwerte werden Pixel unterschiedlich schnell fertiggestellt.
Obwohl der Arbiter die Daten anhand ihrer Pixelposition priorisiert, kann keine vollständig sortierte Reihenfolge garantiert werden.
Ein Pixel kann daher nach Pixeln übertragen werden, die im Bild eigentlich später erscheinen.
Um dennoch eine korrekte Darstellung zu gewährleisten, speichert der Framebuffer die Daten anhand ihrer Pixelkoordinaten und nicht anhand der Reihenfolge ihres Eintreffens.

_@author: Thomas Schiergl_

## 7. VGA

Die VGA-Komponente erzeugt die für den Pmod VGA benötigten Synchronisationssignale sowie die Ausgabe der Farbwerte.
Sie arbeitet unabhängig von der Berechnungslogik und liest die benötigten Pixeldaten aus dem Framebuffer.

### 7.1 VGA-Timing

Für die Bildausgabe wird der Standardmodus 640 × 480 @ 60 Hz verwendet.
Dieser Modus benötigt einen Pixeltakt von ungefähr 25,175 MHz.

_@author: Thomas Schiergl_

## 8. Anmerkungen

### 8.1 Clock Domainen

Ursprünglich war geplant, dass es fünf Clock Domainen gibt.
Eine für die Initialwerterzeugung, eine für die Berechnung, eine für die Farbcodierung, eine für die VGA Pixel Clock und eine für den Prozessor sowie die zugehörigen AXI Schnittstellen.
Jedoch stellte sich heraus, dass die Initialwerterzeugung ohne Änderungen auch auf den 100 MHz des Prozessors läuft.
Daher wurde die AXI Clock der Initialwerterzeugung direkt auf die 100 MHz des Prozessors gelegt um einen Übergang zwischen zwei Clock Domainen zu sparen.
Die Prozessor Clock und Mengenberechnungsclock sind in der endgültigen Implementierung gleich schnell, jedoch ist das System des Arty A7 darauf ausgelegt unterschiedliche Clocks zu unterstützen.
Das wäre nötig, wenn eine höhere maximale Iterationsanzahl angestrebt wird, da ab einem gewissen Punkt die 100 MHz für die Mengenberechnung nicht mehr ausreichen.

_@author: Markus Remy_

### 8.2 Minimap

Ursprünglich war die Minimap als Zusatzfeature für beide FPGAs geplant.
Aufgrund zeitlicher Einschränkungen wurde sie in der Anzeige jedoch nur auf dem Arty Z7 umgesetzt.
Die Initialwertberechnung des Arty A7 unterstützt die Minimap jedoch bereits.

_@author: Markus Remy_

## 9. Zusatzfeature: Portierung auf Arty Z7-20

Da Markus Remy mit den ihm zugeteilten Aufgaben unter den 150 Stunden war und somit noch Puffer hatte, wurde das Projekt auf den Arty Z7-20 portiert.
Da dieser einen HDMI Output hat, wurde die mit der Anzeige sowie dem MicroBlaze verbundene Architektur für HDMI via DVI-D neu entwickelt.
Zusätzlich gab es kleinere Anpassungen in der Architektur des Gesamtsystems um beispielsweise Clock Domain Crossing zu minimieren.

_@author: Markus Remy_

### 9.1 Anzeige mit Farbcodierung

#### 9.1.1 Framebuffer 

Das größte Problem des FractalCore Projekt ist die Knappheit an BRAM.
Somit wird an jeder möglichen Stelle BRAM gespart.
Dementsprechend muss auch bei dem Framebuffer entsprechend gehandelt werden.
Es werden also nur 9 Bit für die Iterationsanzahl und das Konvergenzflag pro Pixel gespeichert anstelle der Farben.
Mit den Daten wird dann zum Zeitpunkt der Ausgabe des Pixels in der Farbcodierung die Farbe ermittelt und ausgegeben.
Zusätzlich wurde die Addressierung dicht gewählt, sodass die BRAMs voll ausgelastet sind.

_@author: Markus Remy_

#### 9.1.2 Sortierung der Ergebnisse

Das zweite große Problem der Anzeige ist das Sortieren der Daten.
Die Daten sind nach der Mengenberechnung unsortiert und müssen ihren ursprünglichen Frames zugeordnet werden.
Dazu werden zwei FIFOs verwendet.
Der erste für gerade Frames und der zweite für ungerade.
Damit können je Frame abwechselnd zwischen den beiden FIFOs Daten entnommen werden und ein von der Mengenberechnung vorgezogenes, kommendes Pixel des nächsten Frames blockiert nicht die nachfolgenden Pixel des letzten Frames.

Die FIFOs wurden in ihrer Größe so gewählt, dass ein Pixel mit der maximalen Berechnungsdauer von 303 Takten bis zum Abbruch von allen drei Stages in den 40 Cores mit je Pixel mit Berechnungsdauern von drei Takten einmal überholt werden kann.

Außerdem wurde das Schreiben der Werte aus den FIFOs in den Framebuffer so implementiert, dass die erste Hälfte des nächsten Frames bereits beschrieben werden darf wenn die VGA Ausgabe in der zweiten Hälfte des vorherigen Frames ist.

_@author: Markus Remy_

#### 9.1.3 Farbcodierung

Für die Farbcodierung wurde ein True Dual Port BRAM gewählt, bei dem das PS (Processing System) über einen BRAM Controller und AXIL auf den einen Port zugreift und die PL (Programmable Logic) über den anderen.
Dabei entsprechen die ersten 256 Addressen den Farben für die jeweilige Iteration.
Die folgenden drei Addressen sind in der genannten Reihenfolge für die Konvergenten Pixel, die Minimap C Koordinaten und das Ziel der Minimap C Koordinaten.
Die Farben werden dabei je Addresse in den unteren 24 der 32 Bit kodiert.
Die niederwertigsten acht Bit sind dabei rot, die folgenden grün und die höchstwertigen acht blau.
Die verbleibenden Bits sind Padding und werden von der PL nicht ausgelesen.

So entfällt der Aufwand ein eigenes AXI Lite Interface mit 259 Registern in RTL zu entwerfen. 

_@author: Markus Remy_

#### 9.1.4 HDMI

Um ein HDMI Signal zu erzeugen wird die Abwärtskompatibilität zu DVI-D genutzt.
Zuerst wird ein VGA Signal mit acht Bits pro Farbe erzeugt.
Dieses liefert aber zusätzlich zu den Synchronisationssignalen auch ein Signal, das aussagt, ob die Daten aktuell im sichtbaren Bereich sind oder nicht.
Dieses Signal wird dann an den [rgb2dvi IP](https://github.com/Digilent/vivado-library/blob/master/ip/rgb2dvi/src/rgb2dvi.vhd) von Digilent gegeben, der es wiederum in ein DVI Signal umwandelt.
Das geschieht indem das Signal mit 8b/10b encoded wird und dann an beiden Flanken auf fünffacher Geschwindigkeit gesendet wird.
Das Signal wird dann direkt auf die HDMI Pins gegeben.

_@author: Markus Remy_

### 9.2 Systemintegration

Für das Arty Z7-20 Projekt wurde sich dazu entschieden, dass es nur drei Clock Domains gibt.
Eine für die VGA Pixel Clock, eine für die DVI Pixel Clock und eine für den Rest.
Das minimiert Clock Domain Crossing und vereinfacht die Constraints.
Das Timing wurde dadurch zwar straffer, jedoch führte das nur zu Problemen beim synchronen Reset.
Dieses Problem wurde gelöst, indem die Resets des Datenpfades der Cores entfernt wurden und nur die Valid Flags resetted werden.
So werden bei 40 Cores mit je drei Stages und vielen Flip Flops je der Reset entfernt, was die Platzierung entzerrt und das Timing, wenn auch nur knapp, erfüllt.

_@author: Markus Remy_

### 9.3 Probleme

#### 9.3.1 Spiegelung der Anzeige

Der erste nach der Inbetriebnahme auffalende Fehler ist die Spiegelung der Anzeige.
Dieser Umstand tritt jedoch nur auf, wenn der 8 Bit Pixelabstand 128 oder größer gewählt wurde.
Damit liegt nahe, dass es einen Überlauf gibt.
Dieser wurde schnell in der Hardware identifiziert.
Die Vorzeichenerweiterung wurde zu früh vollzogen, schon bevor der acht Bit unsigned Abstandswert der Pixel in einen positiven neun Bit signed Wert umgewandelt wurde.
So wurde der Wert also negativ interpretiert.

Diese Änderung hat jedoch den Fehler zuerst nicht behoben, da der IP in Vivado gecached wurde und Vivado nicht erkannt hat, dass es eine Änderung gab.
Erst nach der Neuerstellung des Projekts wurde die Änderung im erstellten Bitstream korrekt abgebildet.

_@author: Markus Remy_

#### 9.3.2 Minimap - Bugs

Die weiteren Fehler beziehen sich auf die Minimap.
Das erste auffällige war, dass teilweise die Zielpixel der LFSR und damit nach einiger Zeit auch der aktuelle Pixel außerhalb der Minimap sind.
Dies liegt daran, dass die Minimap nicht quadratisch ist, der Wertebereich jedoch schon.
Zudem hat sich die Minimap zu Beginn mit dem Zoomfaktor der Anzeige geändert.
Dies konnte jedoch durch einen konstanten Zoom-Faktor für die Minimap behoben werden, der den gesamten Wertebereich der LFSR und Diamond Werte abdeckt.
Dabei wurde der Wertebereich für die beiden Modi so gewählt, dass er statt den maximal möglichen 18 Bit nur 17 Bit verwendet.
So ist der Bereich auch auf der kürzeren Seite der Minimap vollständig abgebildet und die Zielwerte und damit auch die aktuellen Werte werden vollständig auf den sichtbaren Bereich gemappt.

_@author: Markus Remy_

#### 9.3.3 Minimap - Visualisierung

Die Minimap wurde anfangs mit einem Punkt für den Zielwert sowie für den aktuellen Wert entwickelt.
Jedoch irritiert diese Darstellung besondern im LFSR Modus, da der Zielpunkt nicht erreicht wird, sondern nur die beiden Achsen.
Deshalb wurde die Darstellung so geändert, dass nur der aktuelle Punkt ein Punkt ist und der Zielwert als Fadenkreuz dargestellt wird.
Dies bildet das reale Verhalten besser ab, da auch die Achsen für den LFSR Modus abgebildet werden.

_@author: Markus Remy_

#### 9.3.4 HDMI

Das Eingangssignal zum rgb2dvi entspricht nicht wie erwartet dem RGB Schema mit Rot als niederwertigstem Byte folgend von Grün und Blau.
Das Signal benötigt die Werte gedreht.
Dabei entsprechen die acht niederwertigsten Bits der Farbe Grün, die mittleren acht Bits der Farbe Blau und die höchstwertigen Bits der Farbe Rot.

_@author: Markus Remy_