# FractalCore

## Generelles

Das Fractal Core Projekt läuft auf dem Arty A7-100 und dem Arty Z7-20.
Das Arty A7 verwendet einen Pmod VGA zur Ausgabe des Videosignals während das Arty Z7 den integrierten HDMI Output verwendet.

Um mehr Details über das Projekt zu erfahren klicken sie [hier](./docs/Docu.md).

_@author: Markus Remy_

## Einrichtung (Arty A7-100)

Das Projekt wird unter der Verwendung von Vivado und Vitis auf das FPGA geladen.
Dabei wird im folgenden Linux sowie Xilinx Tools der Version 2023.2 vorrausgesetzt.

_@author: Markus Remy_

### Vivado

#### Projekte anlegen

Zuerst müssen vier Vivado Projekte angelegt werden.
Dazu muss das create_all_vivado_projects.sh Skript im Terminal mit gesetzten Vivado Umgebungsvariablen ausgeführt werden.
Um die Vivado Umgebungsvariablen zu setzen muss die im Vivado Installationspfad liegende settings64.sh Datei gescourced werden.
```
source <Pfad_zu_Vivado>/Vivado/2023.2/settings64.sh
```
Dann wird folgender Befehl eingegeben um die Vivado Projekte anzulegen.
```
./scripts/create_all_vivado_projects.sh
```
Die Projekte werden unter xilinx/vivado angelegt.

_@author: Markus Remy_

#### IPs erzeugen

Anmerkung: Dieser Schritt kann übersprungen werden, da die IPs bereits gepackt als Teil des Repositories mitgliefert werden.

Um im FractalCore Projekt auf die Einzelnen IPs zugreifen zu können müssen diese zuerst ins IP Repository aufgenommen werden.
Dazu werden alle drei Projekte in Vivado nacheinander geöffnet und als IP unter hw/ip_repo gepackt.

Dabei sind folgende Schritte auszuführen:
1) Tools -> Create and Package New IP auswählen
2) "Package your current project" auswählen
3) IP location: hw/ip_repo/\<Projektname>
4) Öffnen des temporären Projekts bestätigen
5) Setzen der Parameter unter Identification.
Dabei muss der Name des Projekts ohne Nummer beibehalten werden. (z.B.: Name: Anzeige, Display Name: Anzeige_v1_0)
6) Compatibility -> "Package for IPI" und "Ignore Freq_Hz" anwählen
7) File Groups -> Standard -> Synthesis -> Alle .xdc Dateien mit Rechtsklick -> Entfernen löschen
8) Review and Package -> "Re-Package IP" auswählen

_@author: Markus Remy_

#### Bitstream erzeugen

Wenn bis zu diesem Punkt alle Schritte korrekt ausgeführt wurden ist es ohne Fehler möglich einen Bitstream in Vivado zu erzeugen.
Dazu wird zuerst das FractalCore Vivado Projekt geöffnet-
Dann muss rechts unten unter "Program and Debug" "Generate Bitstream" ausgewählt werden.

Nach Abschluss dieses Schritts wird die Hardwarebeschreibungsdatei exportiert.
Dazu wird unter File -> Export -> Export Hardware... ausgewählt.
Dann wird die Hardwarebeschreibungsdatei inklusive Bitstream unter hw/FractalCore.xsa exportiert.

_@author: Markus Remy_

### Vitis

Um die aus Vivado exportierte Hardwarebeschreibungsdatei für Vitis zu verwenden wird ein Vitis Projekt angelegt.
Dazu muss das create_vitis_project.sh Skript im Terminal mit gesetzten Vitis Umgebungsvariablen ausgeführt werden.
Um die Vitis Umgebungsvariablen zu setzen muss die im Vitis Installationspfad liegende settings64.sh Datei gescourced werden.
```
source <Pfad_zu_Vitis>/Vitis/2023.2/settings64.sh
```
Dann wird folgender Befehl eingegeben um das Vitis Projekt anzulegen und bereits die .elf Datei zu generieren.
```
./scripts/create_vitis_project.sh
```
Dann muss nur noch Vitis mit dem generierten Workspace unter sw/ geöffnet werden und FractalCore_app bei angeschlossenem FPGA ausgeführt werden.

Das Projekt wird dabei temporär in den FPGA geladen und ist nur verfügbar, bis die Stromversorgung unterbrochen wird.

_@author: Markus Remy_

## Einrichtung (Arty Z7-20)

Das Projekt kann auf zwei Arten auf den FPGA geladen werden:

1) Schreiben der BOOT.bin Datei auf eine SD Karte.
2) Erstellen des Projekts und flashen dieses über Vitis.

_@author: Markus Remy_

### BOOT.bin

Die Datei wird auf eine mit FAT32 formatierte SD Karte geschrieben.
Diese wird in das FPGA gesteckt und mit dem entsprechenden Jumper die SD Karte als Bootgerät ausgewählt.

_@author: Markus Remy_

### Vitis

Diese Variante wird für Linux Systeme mit Xilinx Tools der Version 2023.2 beschrieben.

Diese Variante beinhaltet das Erstellen des Bitstreams sowie das Exportieren der Hardwarebeschreibungsdatei (.xsa) mit Vivado.
Da diese jedoch bereits mit im GitHub Repository enthalten ist, kann dieser Schritt auch übersprungen werden.

_@author: Markus Remy_

#### Vivado

Um den Bitream zu erstellen, wird Vivado im Skriptmodus mit dem create_vivado_project.tcl Skript ausgeführt:
```
vivado -mode batch -source "./scripts/create_vivado_project.tcl"
```
Das erstellte Projekt liegt unter xilinx/vivado.
In Vivado muss manuell der Bitstream erstellt werden und dann als Hardware inklusive Bitstream unter hw/FractalCore.xsa exportiert werden.

_@author: Markus Remy_

#### Vitis

Um das Vitis Projekt zu erstellen muss das create_vitis_project.sh Skript im Terminal mit gesetzten Vitis Umgebungsvariablen ausgeführt werden.
Um die Vitis Umgebungsvariablen zu setzen muss die im Vitis Installationspfad liegende settings64.sh Datei gescourced werden.
```
source <Pfad_zu_Vitis>/Vitis/2023.2/settings64.sh
```
Dann wird folgender Befehl eingegeben um das Vitis Projekt anzulegen und bereits die .elf Datei zu generieren.
```
./scripts/create_vitis_project.sh
```
Dann muss nur noch Vitis mit dem generierten Workspace unter sw/ geöffnet werden und FractalCore_app bei angeschlossenem FPGA ausgeführt werden.

Im Gegensatz zur BOOT.bin Methode wird das Projekt nur temporär in den FPGA geladen und ist nur verfügbar, bis die Stromversorgung unterbrochen wird.

_@author: Markus Remy_