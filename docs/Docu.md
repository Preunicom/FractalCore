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