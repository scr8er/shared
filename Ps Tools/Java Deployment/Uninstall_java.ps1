# Ruta de instaladores (VERIFICAR).
$NetSharedFolder = ""
$Java755x86 = "\\$NetSharedFolder\jre-7u55-windows-i586.exe"

#Eliminar registro instalación de Java
remove-item c:\temp\javax86.log

# Versión X86 (VERIFICAR ruta de los instaladores).
start-transcript -path "C:\temp\logJavaUninstall2.txt"
if (Test-Path -path $Java755x86)
    {
    "Localizado instalador, iniciando instalación de Java 7.55 para i586" | Out-Default
    cmd /c "start /w $Java755x86 /s /l c:\temp\javax86.log"
    }
    else
    {
    "No se ha encontrado el instalador. Revisar las rutas." | Out-Default
    }
start-sleep 20

#Eliminar tarea programada.
schtasks /delete /tn "taskjava" /F

#Control de errores
$error1 = "Error 25025.  No se llegó a completar la desinstalación de una versión anterior de Java."
$checkx86 = Get-Content c:\temp\javax86.log | select-string $error1
if ($checkx86)
    {
    " La instalación de java x86 requiere reinicio para iniciarse." | Out-Default
    # Creación de tarea programada (con auto eliminación) para finalizar el proceso de instalación/desinstalación.
    schtasks /create /XML "c:\temp\task.xml" /tn "taskjava" /RU "NT AUTHORITY\SYSTEM"
    }
    else
    {
    " Java se ha instalado correctamente." | Out-Default
    }
stop-transcript
shutdown -r -t 300