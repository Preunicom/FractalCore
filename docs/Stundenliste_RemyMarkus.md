# Stundenliste - Remy Markus

| Datum | Feature | Dauer [h] | Beschreibung | 
|-------|---------|-----------|--------------|
| 21.03.2026 | 8 | 2 | Schnittstellenentwurf (+Diagramm) |
| 22.03.2026 | 8 | 3 | Schnittstellenentwurf (+Diagramm) |
| 25.03.2026 | 8 | 2 | Projektantrag & Systementwurf |
| 25.03.2026 | 8 | 1 | Schnittstellenentwurf |
| 25.03.2026 | 4.1 | 5 | Dispatcher + TB |
| 26.03.2026 | 4.2.1 | 2 | Erster Core Entwurf |
| 27.03.2026 | 4.2.2 | 7 | Kontroll- und Datenpfad ausarbeiten und implementieren + Pipelining |
| 27.03.2026 | 4.2.3 | 3 | TB Control + TB Stage 1 |
| 28.03.2026 | 4.2.3 | 6 | TB Stage 2+3 & TB Core |
| 28.03.2026 | 10 | 1 | Async FIFO IPs |
| 29.03.2026 | 5 | 4 | Arbiter + TB |
| 29.03.2026 | 4.2.1 | 1 | Generate Schleifen für Dispatcher, Core und Arbiter |
| 29.03.2026 | 4.2.3 | 2 | TB Calculation |
| 30.03.2026 | 5 | 3 | Arbiter Pipeline + Rework TB Arbiter |
| 30.03.2026 | 4.2.1 | 1 | Dispatcher Pipeline + Rework TB Dispatcher |

## Feature Nummerierung

1) MicroBlaze (+Treiber)
    1) Instanzieren (1h)
    2) Komponenten Treiber (10h)
    3) Steuerung (5h)
2) Serielle Schnittstelle
    1) UART IP Instanzieren (0.5h)
    2) IP an MicroBlaze anbinden (0.5h)
    3) Menüführung (5h)
    4) Eingabeverarbeitung (10h)
    5) Fehlerbehandlung (2h)
3) Initialwertkomponente
    1) Bildschirmkoord. auf komplex. Zahlen mappen (12h)
    2) Animationssteuerung
        1) Implementierung
            1) AXIL Wrapper (10h)
            2) Animationssteuerung (20h)
        2) Testbenches
            1) AXIL (5h)
            2) Implementierung (5h)
4) Mengenberechnung
    1) Dispatcher (10h)
    2) Rechnen
        1) Implementieren (20h)
        2) Optimieren (25h)
        3) Testbench (5h)
    3) Ergebnismeldung (5h)
5) Arbiter (20h)
6) Farbcodierung
    1) Farbmapping (Ergebnis <-> Farbe) (8h)
    2) Farbschema (7h)
7) VGA
    1) Framebuffer
        1) Schreib-/Lesezugriff (15h)
        2) Zugriff Sync. (20h)
    2) VGA
        1) Pixelclk.anbindung (5h)
        2) Framebufferanbindung (10h)
        3) Bildformaterzeugung (20h)
8) Systementwurf & Schnittstellendefinition (15h)
9) Systemintegration (20h)
10) Clock Domains Crossing (20h)