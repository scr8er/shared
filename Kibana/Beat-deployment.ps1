$repository = ""
$beatsPath = ""
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -force
if (-not(Test-Path "c:\temp")) {
    mkdir c:\temp -force
    $delete = $true
}
Copy-Item -path $repository -destination "c:\temp\BeatPlugIns-deployment.ps1"
& 'c:\temp\BeatPlugIns-deployment.ps1'
Write-Host "Restaurando la politica de ejecucion." -ForegroundColor DarkGreen
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy remotesigned -force -Verbose
Get-Service *beat
Write-Host "Revisar el log de la ejecución" -ForegroundColor DarkGreen
notepad.exe "c:\temp\ExecutionLog.log"
if ($delete) {
    Write-Host "Limpieza de archivos ejecutados." -ForegroundColor DarkGreen
    Remove-Item c:\temp -force -Verbose
}
else {
    Write-Host "Limpieza de archivos ejecutados." -ForegroundColor DarkGreen
    Remove-Item "c:\temp\BeatPlugIns-deployment.ps1" -Force -Verbose
    Remove-Item "c:\temp\ExecutionLog.log"
}


Start-Transcript -Path "c:\temp\ExecutionLog.log"

#$credentials = Get-Credential
$BeatServices = @("auditbeat", "metricbeat", "winlogbeat")
$InstallationPath = "C:\Program Files\Kibana"
$SourcePath = $beatsPath
if (-not (Test-Path $InstallationPath)) {
    mkdir $InstallationPath -Force
    mkdir $InstallationPath\auditbeat -Force
    mkdir $InstallationPath\metricbeat -Force
    mkdir $InstallationPath\winlogbeat -Force
}
Get-ChildItem -path $SourcePath -Directory | ForEach-Object -Process {
    if ($_.name -like "auditbeat*") {
        Get-ChildItem $_.FullName | Copy-Item -Destination "$InstallationPath\auditbeat" -Recurse -Force
    }
    elseif ($_.name -like "metricbeat*") {
        Get-ChildItem $_.FullName | Copy-Item -Destination "$InstallationPath\metricbeat" -Recurse -Force
    }
    elseif ($_.name -like "winlogbeat*") {
        Get-ChildItem $_.FullName | Copy-Item -Destination "$InstallationPath\winlogbeat" -Recurse -Force
    }

}
foreach ($BeatService in $BeatServices) {
    & "$InstallationPath\$BeatService\install-service-$BeatService.ps1"
}

foreach ($BeatService in $BeatServices) {
    $check = get-service $beatservice
    if ($check.Status -ne "running") {
        Write-Host "iniciando servicio $beatservice" -ForegroundColor Green
        Start-Service $BeatService
    }
    else {
        Write-Host "El servicio $beatservice está corriendo" -ForegroundColor DarkGreen
    }
}
Get-Service *beat
Stop-Transcript