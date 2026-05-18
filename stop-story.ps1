# In den Ordner des Skripts wechseln
Set-Location $PSScriptRoot

Write-Host "[1/3] Fahre SillyTavern herunter..." -ForegroundColor Cyan
docker compose down

Write-Host "[2/3] Bereite Git-Commit vor..." -ForegroundColor Cyan
git add .

# Zeitstempel für die Commit-Nachricht generieren
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Story-Fortschritt: $date"

Write-Host "[3/3] Pushe Änderungen zu GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host "`nErfolgreich beendet und auf GitHub gesichert!" -ForegroundColor Green
Read-Host -Prompt "Drücke Enter zum Schliessen"
