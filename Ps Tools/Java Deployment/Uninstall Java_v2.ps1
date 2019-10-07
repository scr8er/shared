# Ruta de instaladores (VERIFICAR).
$Java755x86 = "c:\temp\javax86v755.exe"
$Java755x64 = "c:\temp\javax64v755.exe"

# Ruta registro x86 x64
$softwarex64 = gci HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
$softwarex86 = gci HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall  | foreach-object {Get-ItemProperty $_.PsPath}

# Se habilita log de registro para depuración.
Start-transcript -path "C:\temp\logJavaUninstall.txt"

cls

"-----------------------------------------------------------------------------------" | Out-Default
"                                DESINTALACIÓN JAVA v1                              " | Out-Default
"-----------------------------------------------------------------------------------" | Out-Default
" " | Out-Default
" Se desintalarán todas las versiones de Java localizadas en el sistema" | Out-Default
" " | Out-Default

# finalizamos procesos java para la desinstalación.
taskkill /f /im java.exe

# Desintalación por Registro 1/3 mediante cadena de desinstalación silenciosa predefinida "QuietUninstallString".
$UninstallStringx64 = $softwarex64 | ? { $_.displayname -match "Java" } | select QuietUninstallString
$UninstallStringx86 = $softwarex86 | ? { $_.displayname -match "Java" } | select QuietUninstallString
if ($UninstallStringx64.QuietUninstallString)
    {cmd /c $UninstallStringx64.QuietUninstallString /quiet}
if ($UninstallStringx86.QuietUninstallString)
    {cmd /c $UninstallStringx86.QuietUninstallString /quiet}

# Desintalación por Registro 2/3 mediante cadena predefinida "UninstallString".
$UninstallStringx64 = $softwarex64 | ? { $_.displayname -match "Java" } | select UninstallString
$UninstallStringx86 = $softwarex86 | ? { $_.displayname -match "Java" } | select UninstallString
if ($UninstallStringx86.UninstallString)
    {cmd /c $UninstallStringx86.UninstallString /quiet}
if ($UninstallStringx64.UninstallString)
    {cmd /c $UninstallStringx64.UninstallString /quiet}

# Desintalación por WMI 3/3
Get-WmiObject Win32_product -filter "name like 'Java%'" | % { $_.Uninstall() }

"-----------------------------------------------------------------------------------" | Out-Default
"                           INSTALACIÓN JAVA 7.55 x64 y x86                         " | Out-Default
"-----------------------------------------------------------------------------------" | Out-Default
" " | Out-Default
" A continuación se instalarán las versiones 7.55 para x86 y x64" | Out-Default
" " | Out-Default

# Instalación Java 7.55 (requiere aprobación UAC).
" " | Out-Default
" A continuación se instalará la versión de Java 7.55" | Out-Default
" " | Out-Default

# Versión X64 (VERIFICAR ruta de los instaladores).
if (Test-Path -path $Java755x64)
    {
    cmd /c "start /w $java755x64 /s"
    }

# Versión X86 (VERIFICAR ruta de los instaladores).
if (Test-Path -path $Java755x86)
    {
    cmd /c "start /w $java755x86 /s"
    }

# Detener registro de depuración.
Stop-Transcript