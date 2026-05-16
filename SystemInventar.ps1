# =============================
# SystemInventar.ps1
# Beschreibung: System-Inventar
# Autor: Greub Marc
# Version: 1.0
# ===============================

$Datum      = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
$DatumDatei = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Ordner automatisch neben dem Skript erstellen
$SkriptOrdner = $PSScriptRoot
$ReportOrdner = "$SkriptOrdner\Reports"

if (-not (Test-Path $ReportOrdner)) {
    New-Item -ItemType Directory -Path $ReportOrdner | Out-Null
}

$ReportPfad = "$ReportOrdner\SystemReport_$($env:COMPUTERNAME)_$DatumDatei.html"

# Hilfsfunktion für Überschriften
function Write-Titel {
    param($Text)
    Write-Host ""
    Write-Host "================================" -ForegroundColor DarkGray
    Write-Host "  $Text" -ForegroundColor Blue
    Write-Host "================================" -ForegroundColor DarkGray
}

Write-Host "Starte Inventarisierung..." -ForegroundColor Cyan
Write-Host "Datum: $Datum" -ForegroundColor DarkGray

# Betriebssystem-Informationen holen
$OS = Get-CimInstance Win32_OperatingSystem

Write-Titel "BETRIEBSSYSTEM"
Write-Host "Betriebssystem: $($OS.Caption)"
Write-Host "Version:        $($OS.Version)"
Write-Host "Architektur:    $($OS.OSArchitecture)"

# CPU-Informationen holen
$CPU = Get-CimInstance Win32_Processor

Write-Titel "CPU"
Write-Host "CPU:             $($CPU.Name)"
Write-Host "Kerne:           $($CPU.NumberOfCores)"
Write-Host "Logische Kerne:  $($CPU.NumberOfLogicalProcessors)"
Write-Host "Auslastung:      $($CPU.LoadPercentage) %"

# RAM-Information holen
$RAM = Get-CimInstance Win32_OperatingSystem

$Gesamt = [math]::Round($RAM.TotalVisibleMemorySize / 1MB, 2)
$Frei   = [math]::Round($RAM.FreePhysicalMemory / 1MB, 2)
$Belegt = [math]::Round($Gesamt - $Frei, 2)

Write-Titel "RAM"
Write-Host "RAM Gesamt: $Gesamt GB"
Write-Host "RAM Belegt: $Belegt GB"
Write-Host "RAM Frei:   $Frei GB"

# Festplatten-Informationen holen
$Laufwerke = Get-PSDrive -PSProvider FileSystem

Write-Titel "LAUFWERKE"
foreach ($L in $Laufwerke) {
    $LGesamt = [math]::Round(($L.Used + $L.Free) / 1GB, 2)
    $LFrei   = [math]::Round($L.Free / 1GB, 2)
    $LBelegt = [math]::Round($L.Used / 1GB, 2)
    Write-Host "  Laufwerk $($L.Name): | Gesamt: $LGesamt GB | Belegt: $LBelegt GB | Frei: $LFrei GB"
}

# Netzwerk-Informationen holen
$Netzwerk = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

Write-Titel "NETZWERK"
foreach ($N in $Netzwerk) {
    $GW = if ($N.DefaultIPGateway) { $N.DefaultIPGateway[0] } else { "kein Gateway" }
    Write-Host "  Adapter:     $($N.Description)"
    Write-Host "  IP-Adresse:  $($N.IPAddress[0])"
    Write-Host "  Gateway:     $GW"
    Write-Host "  MAC-Adresse: $($N.MACAddress)"
    Write-Host ""
}

# Grafikkarten-Informationen holen
$GPU = Get-CimInstance Win32_VideoController | Where-Object { $_.CurrentHorizontalResolution -gt 0 }

Write-Titel "GRAFIKKARTE"
foreach ($G in $GPU) {
    Write-Host "  Name:       $($G.Name)"
    Write-Host "  Treiber:    $($G.DriverVersion)"
    Write-Host "  Aufloesung: $($G.CurrentHorizontalResolution) x $($G.CurrentVerticalResolution)"
    Write-Host ""
}

# Installierte Software holen
$Software = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -ne $null } |
    Sort-Object DisplayName

Write-Titel "INSTALLIERTE SOFTWARE"
foreach ($S in $Software) {
    Write-Host "  $($S.DisplayName) - $($S.DisplayVersion)"
}

Write-Titel "FERTIG"
Write-Host "  Report erstellt am: $Datum" -ForegroundColor Cyan
Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "  Benutzer: $env:USERNAME" -ForegroundColor Cyan

# HTML-Report erstellen
$HTML = @"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>System-Inventar $env:COMPUTERNAME</title>
    <style>
        body { font-family: Arial, sans-serif; background: #1e1e1e; color: #d4d4d4; padding: 30px; }
        h1   { color: #58a6ff; }
        h2   { color: #0094f0; border-bottom: 1px solid #444; padding-bottom: 5px; }
        p    { color: #d4d4d4; margin: 4px 0; }
        .box { background: #2d2d2d; border-radius: 8px; padding: 16px; margin-bottom: 20px; }
        .balken-wrap { background: #444; border-radius: 6px; height: 14px; width: 100%; margin-top: 4px; }
        .balken      { height: 14px; border-radius: 6px; background: #58a6ff; }
        .balken.warn { background: #f0a500; }
        .balken.crit { background: #e74c3c; }
        .label-row   { display: flex; justify-content: space-between; margin-top: 8px; }
    </style>
</head>
<body>

    <h1>System-Inventar: $env:COMPUTERNAME</h1>
    <p>Erstellt am: $Datum | Benutzer: $env:USERNAME</p>

    <h2>Betriebssystem</h2>
    <div class="box">
        <p>Betriebssystem: $($OS.Caption)</p>
        <p>Version: $($OS.Version)</p>
        <p>Architektur: $($OS.OSArchitecture)</p>
    </div>

    <h2>CPU</h2>
    <div class="box">
$(
    $CPULast = if ($CPU.LoadPercentage) { $CPU.LoadPercentage } else { 0 }
    "        <p>CPU: $($CPU.Name)</p>"
    "        <p>Kerne: $($CPU.NumberOfCores) | Logische Kerne: $($CPU.NumberOfLogicalProcessors)</p>"
    "        <div class='label-row'><span>Auslastung</span><span>$CPULast %</span></div>"
    "        <div class='balken-wrap'><div class='balken$(if ($CPULast -gt 90) {" crit"} elseif ($CPULast -gt 70) {" warn"})' style='width:$($CPULast)%'></div></div>"
)
    </div>

    <h2>RAM</h2>
    <div class="box">
$(
    $RAMProzent = [math]::Round(($Belegt / $Gesamt) * 100, 0)
    "        <p>Gesamt: $Gesamt GB | Belegt: $Belegt GB | Frei: $Frei GB</p>"
    "        <div class='label-row'><span>Auslastung</span><span>$RAMProzent %</span></div>"
    "        <div class='balken-wrap'><div class='balken$(if ($RAMProzent -gt 90) {" crit"} elseif ($RAMProzent -gt 70) {" warn"})' style='width:$($RAMProzent)%'></div></div>"
)
    </div>

    <h2>Laufwerke</h2>
    <div class="box">
$(foreach ($L in $Laufwerke) {
    $LGesamt = [math]::Round(($L.Used + $L.Free) / 1GB, 2)
    $LFrei   = [math]::Round($L.Free / 1GB, 2)
    $LBelegt = [math]::Round($L.Used / 1GB, 2)
    "        <p>Laufwerk $($L.Name): | Gesamt: $LGesamt GB | Belegt: $LBelegt GB | Frei: $LFrei GB</p>"
})
    </div>

    <h2>Netzwerk</h2>
    <div class="box">
$(foreach ($N in $Netzwerk) {
    $GW = if ($N.DefaultIPGateway) { $N.DefaultIPGateway[0] } else { "kein Gateway" }
    "        <p>Adapter: $($N.Description)</p>"
    "        <p>IP: $($N.IPAddress[0]) | Gateway: $GW | MAC: $($N.MACAddress)</p>"
    "        <br>"
})
    </div>

    <h2>Grafikkarte</h2>
    <div class="box">
$(foreach ($G in $GPU) {
    $VRAM = [math]::Round($G.AdapterRAM / 1GB, 0)
    "        <p><strong>Name:</strong> $($G.Name)</p>"
    "        <p><strong>Treiber:</strong> $($G.DriverVersion)</p>"
    "        <p><strong>Aufloesung:</strong> $($G.CurrentHorizontalResolution) x $($G.CurrentVerticalResolution)</p>"
    "        <p><strong>VRAM:</strong> $VRAM GB</p>"
    "        <br>"
})
    </div>

    <h2>Installierte Software</h2>
    <div class="box">
$(foreach ($S in $Software) {
    "        <p>$($S.DisplayName) - $($S.DisplayVersion)</p>"
})
    </div>

</body>
</html>
"@

$HTML | Out-File -FilePath $ReportPfad -Encoding UTF8
Write-Host ""
Write-Host "HTML-Report gespeichert: $ReportPfad" -ForegroundColor Green
Start-Process $ReportPfad