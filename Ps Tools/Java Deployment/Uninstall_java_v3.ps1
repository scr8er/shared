# SDT 2019
Start-transcript -path "C:\temp\logJavaUninstall.txt"
Clear-host
"-----------------------------------------------------------------------------------" | Out-Default
"                                DESINTALACIÓN JAVA v1                              " | Out-Default
"-----------------------------------------------------------------------------------" | Out-Default
" " | Out-Default
" Se desintalarán todas las versiones de Java localizadas en el sistema" | Out-Default
" " | Out-Default
#
pause
#
function DescargarArchivo([string]$URLOrigen, [string]$destino)
{
  Remove-Item -Path $destino -Force -ErrorAction Ignore
  Invoke-WebRequest $RULOrigen -OutFile $destino
}
#
# Desintalación por WMI (desatendida)
Get-WmiObject Win32_product -filter "name like 'Java%'" | Foreach-Object { $_.Uninstall() }

#Desintalación por Registro (Desatendida)
$softwarex64 = Get-Childitem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
$softwarex86 = Get-Childitem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall  | foreach-object {Get-ItemProperty $_.PsPath}
$UninstallStringx64 = $softwarex64 | Where-Object { $_.displayname -match "Java" } | Select-Object QuietUninstallString
$UninstallStringx86 = $softwarex86 | Where-Object { $_.displayname -match "Java" } | Select-Object QuietUninstallString
$UninstallStringx64.QuietUninstallString
$UninstallStringx86.QuietUninstallString

#Desintalación por Registro (interactiva)
$softwarex64 = Get-Childitem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
$softwarex86 = Get-Childitem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall  | foreach-object {Get-ItemProperty $_.PsPath}
$UninstallStringx64 = $softwarex64 | Where-Object { $_.displayname -match "Java" } | Select-Object UninstallString
$UninstallStringx86 = $softwarex86 | Where-Object { $_.displayname -match "Java" } | Select-Object UninstallString
$UninstallStringx64.UninstallString
$UninstallStringx86.UninstallString

#Instalación Java 7.55
" " | Out-Default
" A continuación se instalará la versión de Java 7.55" | Out-Default
" " | Out-Default
$Java755x32 = "c:\temp\javax32v755.exe"
$Java755x64 = "c:\temp\javax64v755.exe"
#
# Versión X64
#
if (Test-Path -path $Java755x64)
    {
    cmd /c "start /w C:\temp\javax64v755.exe /s"
    }
else
    {
    #x64
    DescargarArchivo -sourceUrl javadl.sun.com/webapps/download/AutoDL?BundleId=87443 -destinationFile $Java755x64 -force
    cmd /c "start /w C:\temp\javax64v755.exe /s"
    }
#
# Versión X32
#
if (Test-Path -path $Java755x32)
    {
    cmd /c "start /w C:\temp\javax32v755.exe /s"
    }
else
    {
    #x32
    DescargarArchivo -sourceUrl javadl.sun.com/webapps/download/AutoDL?BundleId=86895 -destinationFile $Java755x32 -force
    cmd /c "start /w C:\temp\javax32v755.exe /s"
    }
stop-transcript