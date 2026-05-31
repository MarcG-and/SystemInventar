# 🖥️ SystemInventar.ps1

> Automatisiertes PowerShell-Tool zur Erfassung von Systeminformationen mit HTML-Report-Export.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey?logo=windows)
![Version](https://img.shields.io/badge/Version-1.0-green)

---

## 📋 Beschreibung

**SystemInventar.ps1** liest automatisch alle wichtigen Hardware- und Softwareinformationen eines Windows-PCs aus und erstellt daraus einen professionellen HTML-Report, der sich direkt im Browser öffnet.

Das Skript ist auf jedem Windows-System ohne Installation lauffähig und speichert die Reports chronologisch in einem eigenen Unterordner.

---

## ⚙️ Funktionen

| Bereich | Erfasste Daten |
|---|---|
| 🖥️ Betriebssystem | Name, Version, Architektur |
| ⚡ CPU | Modell, Kerne, Auslastung (mit Balken) |
| 🧠 RAM | Gesamt, Belegt, Frei (mit Balken) |
| 💾 Laufwerke | Alle Partitionen mit Speicherplatz |
| 🌐 Netzwerk | Adapter, IP, Gateway, MAC-Adresse |
| 🎮 Grafikkarte | Name, Treiber, Auflösung, VRAM |
| 📦 Software | Alle installierten Programme |

### Report-Features
- 📊 Grafische Fortschrittsbalken für CPU & RAM
- 🟡 Orange ab 70% Auslastung
- 🔴 Rot ab 90% Auslastung
- 📁 Chronologische Speicherung mit Datum & Computername
- 🌙 Dunkles Design

---

## 🚀 Starten

### Voraussetzungen
- Windows 10 / 11
- PowerShell 5.1 oder neuer

### Einmalige Einrichtung
ExecutionPolicy einmalig setzen (PowerShell als Administrator):
```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
```

### Skript ausführen
```powershell
cd "Pfad\zum\Skript"
.\SystemInventar.ps1
```

### Oder per Verknüpfung (Doppelklick)
Verknüpfung mit folgendem Ziel erstellen:
```
powershell.exe -ExecutionPolicy Bypass -File "Pfad\zum\Skript\SystemInventar.ps1"
```

---

## 📁 Dateistruktur

```
SystemInventar/
│
├── SystemInventar.ps1        # Hauptskript
├── README.md                 # Diese Dokumentation
├── .gitignore                # Schliesst Reports-Ordner aus
│
└── Reports/                  # Automatisch erstellt
    ├── SystemReport_PC-Name_2026-05-01_14-30-00.html
    ├── SystemReport_PC-Name_2026-05-03_09-15-00.html
    └── ...
```

---

## 🛠️ Verwendete Technologien

- **PowerShell** — Skriptlogik und Datenerfassung
- **CIM / WMI** — Hardwareinformationen aus Windows auslesen
- **HTML / CSS** — Visueller Report im Browser
- **Windows Registry** — Installierte Software auslesen
- **Git / GitHub** — Versionierung und Veröffentlichung

---

## 📸 Report-Vorschau

```
================================
  BETRIEBSSYSTEM
================================
Betriebssystem: Windows 11 Pro
Version:        10.0.26200
Architektur:    64-Bit

================================
  CPU
================================
CPU:             AMD Ryzen 9 7900 12-Core Processor
Kerne:           12
Logische Kerne:  24
Auslastung:      3 %
```

---

## 👤 Autor

**Greub Marc**
Informatiker Ausbildung | Schweiz

---

*Entwickelt als Portfolio-Projekt im Rahmen der Informatiker-Ausbildung.*
