# In den Ordner des Skripts wechseln
Set-Location $PSScriptRoot

Write-Host "[1/3] Hole neuesten Stand von GitHub..." -ForegroundColor Cyan
git pull origin main

Write-Host "[2/3] Starte SillyTavern..." -ForegroundColor Cyan
docker compose up -d

Write-Host "[3/3] Öffne SillyTavern im Browser..." -ForegroundColor Cyan
Start-Process "http://localhost:8000"

Write-Host "`nBereit zum Schreiben! Lass dieses Fenster offen. Nutze stop-story.ps1 zum Beenden." -ForegroundColor Green
