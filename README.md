# FractalCore (ArtyZ7-20)

## Generelles

Standardmäßig läuft das Fractal Core Projekt auf dem Arty A7, dieser Branch portiert es jedoch auf den Arty Z7-20.
Aufgrund der zur Verfügung stehenden Hardware wird als Ausgabe statt VGA, HDMI auf Basis von DVI-D verwendet.
Dafür wird die Architektur nach der Mengenberechnung sowie das Konfigurationsmodul von Grund auf neu entwickelt.

Dieser Branch entspricht einem zusätzlichen Feature und ist nicht in der ursprünglichen Projektbescheibung des Kurses DAPI enthalten.

Um mehr über spezifische Design Entscheidungen zu erfahren klicken sie [hier](./docs/Docu.md).

_@author: Markus Remy_

## Einrichtung (ArtyZ7-20)

Um das Projekt auf den FPGA zu bekommen gibt es zwei Herangehensweisen:

1) Schreiben der BOOT.bin Datei auf eine SD Karte.
2) Erstellen des Projekts und flashen dieses über Vitis.

_@author: Markus Remy_

### BOOT.bin

Die Datei wird auf eine mit FAT32 formatierte SD Karte geschrieben.
Diese wird in das FPGA gesteckt und als Bootgerät die SD Karte gewählt.

_@author: Markus Remy_

### Vitis

Diese Variante wird für Linux Systeme beschrieben.

Die ausführliche Variante beinhaltet das erstellen des Bitstreams über Vivado.
Da dieser jedoch bereits mit im Projekt enthalten ist, kann dieser Schritt auch übersprungen werden.

_@author: Markus Remy_

#### Vivado

Um den Bitream zu erstellen, wird vivado im Skriptmodus mit dem create_vivado_project.tcl Skript ausgeführt:
```
vivado -mode batch -source "./scripts/create_vivado_project.tcl"
```
Das erstellte Projekt liegt unter xilinx/vivado.
In Vivado wird manuell der Bitstream erstellt und dann als Hardware unter hw/FractalCore.xsa exportiert.

_@author: Markus Remy_

#### Vitis

Um das Vitis Projekt zu erstellen wird das create_vitis_project.sh Skript im Terminal mit gesetzten Vitis Umgebungsvariablen ausgeführt.
Um die Vitis Umgebungsvariablen zu setzen wird die im Vitis Installationspfad liegende settings64.sh Datei gescourced.
Dann wird folgender Befehl eingegeben um das Vitis Projekt anzulegen und bereits die .elf Datei zu generieren.
```
./scripts/create_vitis_project.sh
```
Dann muss nur noch Vitis geöffnet werden und FractalCore_app bei angeschlossenem FPGA ausgeführt werden.

Im Gegensatz zur BOOT.bin Methode wird das Projekt nur temporär in den FPGA geladen und ist nur verfügbar, bis die Stromverbindung ausfällt.

_@author: Markus Remy_