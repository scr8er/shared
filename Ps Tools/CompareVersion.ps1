        [version]$tools = Get-Content "c:\temp\prueba.txt"
        [version]$tools_version = "10.2.1"

            If ($tools -le $tools_version)
            {
               Write-host "Actualizar version de VmWare tools v.$tools a 10.2.1 a es1terbidi80v" -ForegroundColor yellow
               #Get-VMGuest $equipo | Update-Tools -NoReboot
               # Registro
               #Write-Output "$fecha_ejecucion Se ha solicitado la actualizacion de VmWare tools v.$tools a v.10.2.1 para $equipo"  | Out-File $ruta\"$equipo"_"$fecha"_$registro -Append
            }
            else
            {
               # Registro
               Write-host "La version de VmWare tools v.$tools es igual o superior a la necesaria en es1terbidi80v"
            }