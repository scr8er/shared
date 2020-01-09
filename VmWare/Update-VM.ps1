# Definición de constantes.
[string]$NICNameSource = @("e1000","Flexible","vmxnet","EnhancedVmxnet"); # Tarjeta virtual obsoleta
[string]$NICNameTarget = "Vmxnet3" # Tarjeta virtual deseada
[string]$HardwareVersionTarget = "vmx-13" # Versión objetivo de VMhardware.
[version]$VmWareToolsTarget = "11.0.0" # Versión objetivo de VMTools

###################################################################### Listado de máquinas para analizar.
Clear-Variable TestVM
$TestVM = ""
########################################################################################################
function SDUpgradeVM {
    $VMList = foreach ($Name in $TestVM) {
        Get-VM -name $Name | Select-Object Name, PowerState, HardwareVersion, ExtensionData
    }
    ForEach ($vm in $vmList) {
        Write-Host "`nAnalizando VM" (Get-VM $vm.name).guest.hostname -ForegroundColor Green

        # Reiniciar comprobaciones, limpiar variables.
        [bool]$CheckHW = $false
        [bool]$CheckTools = $false
        [bool]$CheckNIC = $false
        [bool]$Status = $false
        Clear-Variable Tools, VMNic, VmIPAddress, VmName, CheckOS, PowerStatus -ErrorAction Ignore

        # Comprobación de SO
        [string]$CheckOS = (Get-VM -name $vm.name | Get-VMGuest).OSFullName
        If (-not($CheckOS | Select-String "Windows")) {
            Write-Host "Sistema operativo:" $CheckOS "saltando a la siguiente maquina virtual"-ForegroundColor Blue
            continue
        }
        else {
            Write-Host "Sistema operativo:" $CheckOS -ForegroundColor Blue
        }

        # Excepciones
        [version]$Tools = (Get-VM $vm.name).guest.ToolsVersion
        if (($null -eq $Tools) -or ($Tools -eq "")) {
            Write-Host "`n`nNo existe ninguna versión de VmTools, no se realizarán acciones sobre" $Vm.Name -ForegroundColor Red
            Pause
            continue
        }

        #Comprobación de NIC
        $VmIPAddress = (Get-VM $vm.name).Guest.ipaddress
        $VmIPAddress
        foreach ($NIC in $NICNameSource) {
            if ((Get-VM $vm.name | Get-NetworkAdapter).type | Select-String $NIC) {
                Write-Host "Es necesario actualizar drivers de la NIC a $NICNameTarget." -ForegroundColor Green
                $CheckNIC = $true
                break;
            }
        }

        #Comprobacion de HWVersion
        if ($Vm.HardwareVersion -notmatch $HardwareVersionTarget) {
            Write-Host "Es necesario actualizar la versión de hardware actual de" $Vm.HardwareVersion "a" $HardwareVersionTarget -ForegroundColor Green
            $CheckHW = $true
        }

        #Comprobacion de VmTools
        if ($tools -lt $VmWareToolsTarget) {
            Write-Host "Es necesario actualizar la versión de VmWareTools de $tools a $VmWareToolsTarget" -ForegroundColor Green
            $CheckTools = $true
        }

        If (-not(($checkHW) -or ($checkNIC) -or ($CheckTools))) {
            Write-Host "No se han detectado elementos para actualizar." -ForegroundColor Red
            continue
        }
        else {
            Write-Host "Verificar IP de la red de produccion antes de iniciar el apagado." (Get-VM $vm.name).guest.hostname "," $VmIPAddress -ForegroundColor Yellow
            [String]$Question = Read-Host "`n¿Desea aplicar los cambios a la VM? Y/N"
            if ($Question -ne "Y") {
                Write-Host "Saltando a la siguiente maquina virtual"
                continue
            }

            # Comprobaciones previas al apagado.
            if ($vm.Name -like "one*") {
                [string]$vmName = $vm.Name | ForEach-Object { $_.Split('-')[2]; }
            }
            else {
                [string]$vmName = $vm.Name
            }
            Write-Host "Comprobando resolucion de hostname: $VmName"
            If ($vm.ExtensionData.Guest.GuestFullName -like "Microsoft*") {
                [bool]$status = (Test-NetConnection -Port 3389 -ComputerName $vmName).TcpTestSucceeded
            }
            else {
                [bool]$status = (Test-NetConnection -Port 22 -ComputerName $vmName).TcpTestSucceeded
            }
            Write-Host "$VmName $VmIPAddress $status"

            # Secuencia de apagado y comprobaciones previas.
            If (($checkHW) -or ($checkNIC) -or ($CheckTools)) {

                # Secuencia de cambios, crear plantilla de configuración de VM.
                $vmConfig = Get-View -VIObject $vm.Name
                $vmNewConfig = New-Object VMware.Vim.VirtualMachineConfigSpec

                # Modificar versión de Hardware
                If ($CheckHW) {
                    Write-Host "Habilitando actualización de versión de hardware al reiniciar." -ForegroundColor Green
                    $vmNewConfig.ScheduledHardwareUpgradeInfo = New-Object VMware.Vim.ScheduledHardwareUpgradeInfo
                    $vmNewConfig.ScheduledHardwareUpgradeInfo.UpgradePolicy = "always"
                    $vmNewConfig.ScheduledHardwareUpgradeInfo.VersionKey = $hardwareVersion
                    $vmConfig.ReconfigVM($vmNewConfig)
                }

                # Modificar versión de VmTools
                If ($CheckTools) {
                    Write-Host "Habilitando actualización de versión de tools al reiniciar." -ForegroundColor Green
                    $vmNewConfig.Tools = New-Object VMware.Vim.ToolsConfigInfo
                    $vmNewConfig.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle"
                    $vmConfig.ReconfigVM($vmNewConfig)
                }

                Write-Host "Iniciando apagado de máquina virtual." -ForegroundColor Green
                [int]$Count = 0
                Shutdown-VMGuest -VM $vm.Name -Confirm:$true
                do {
                    Start-Sleep -Seconds 10
                    $PowerStatus = (Get-VM $vm.Name).PowerState
                    $Count++
                    if ($Count -gt 10) {
                        Stop-VM -VM $vm.Name -Kill -Confirm:$false
                    }
                }
                until ($PowerStatus -eq "PoweredOff")
                Write-Host "La maquina" $vm.Name "esta apagada" -ForegroundColor Green

                # Modificar tipo de tarjeta de red virtual.
                If ($CheckNIC) {
                    $VmNetworkAdapter = Get-VM -name $vm.name | Get-NetworkAdapter
                    ForEach ($NIC in $VmNetworkAdapter) {
                        If ($NIC.type -eq $NicNameSource) {
                            Write-Host "Modificando tarjeta $NicNameSource por $NICNameTarget" -ForegroundColor Green
                            Set-NetworkAdapter -NetworkAdapter $NIC -Type $NICNameTarget -Confirm:$true
                        }
                    }
                }

                # Consolidación de información de SO.
                If ($vm.ExtensionData.Config.GuestFullName -notmatch $vm.ExtensionData.Guest.GuestFullName) {
                    Write-Host "El SO" $vm.ExtensionData.Guest.GuestFullName "no es el mismo que el que esta configurado" $vm.ExtensionData.Config.GuestFullName -ForegroundColor Red
                    $vm.ExtensionData.Guest.GuestFullName
                    switch ($vm.ExtensionData.Guest.GuestFullName) {
                        "Oracle Linux 8 (64-bit)" {
                            $newSO = "oracleLinux8_64Guest";
                            break
                        }
                        "Oracle Linux 7 (64-bit)" {
                            $newSO = "oracleLinux7_64Guest";
                            break
                        }
                        "Oracle Linux 7" {
                            $newSO = "oracleLinux7Guest";
                            break
                        }
                        "Oracle Linux 6 (64-bit)" {
                            $newSO = "oracleLinux6_64Guest";
                            break
                        }
                        "Oracle Linux 6" {
                            $newSO = "oracleLinux6Guest";
                            break
                        }
                        "Oracle Linux 4/5 (64-bit)" {
                            $newSO = "oracleLinux64Guest";
                            break
                        }
                        "Oracle Linux 4/5" {
                            $newSO = "oracleLinuxGuest";
                            break
                        }
                        "Red Hat Enterprise Linux 8 (64 bit)" {
                            $newSO = "rhel8_64Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 7 (64 bit)" {
                            $newSO = "rhel7_64Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 7" {
                            $newSO = "rhel7Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 6 (64 bit)" {
                            $newSO = "rhel6_64Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 6" {
                            $newSO = "rhel6Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 5 (64-bit)" {
                            $newSO = "rhel5_64Guest";
                            break
                        }
                        "Red Hat Enterprise Linux 5" {
                            $newSO = "rhel5Guest";
                            break
                        }
                        "Microsoft Windows Server 2016 (64 bit)" {
                            $newSO = "windows9Server64Guest";
                            break
                        }
                        "Microsoft Windows Server 2012 (64-bit)" {
                            $newSO = "windows8Server64Guest";
                            break
                        }
                        "Microsoft Windows Server 2008 R2 (64 bit)" {
                            $newSO = "windows7Server64Guest";
                            break
                        }
                        "Microsoft Windows Server 2008 (32-bit)" {
                            $newSO = "windows7ServerGuest";
                            break
                        }
                        Default {
                            $newSO = $null;
                            Write-Host SO no soportado
                            break
                        }
                    }
                    If ($null -ne $newSO) {
                        Set-VM -VM $vm.Name -GuestId $newSO -Confirm:$false
                        Write-Host "Cambiando SO" -ForegroundColor Green
                    }
                }
                else {
                    Write-Host "El SO que corre" $vm.ExtensionData.Guest.GuestFullName "es el mismo que el que esta configurado" $vm.ExtensionData.Config.GuestFullName -ForegroundColor Green
                }

                Write-Host "Iniciar máquina virtual."
                Pause
                Start-VM -VM $vm.Name
                [int]$clock = 0
                do {
                    if (-not($clock -eq 0)) {
                        Start-Sleep -Seconds 60
                    }
                    Write-Host "Comprobando si hay conexion con $VmName" -ForegroundColor Blue
                    If ($vm.ExtensionData.Guest.GuestFullName -like "Microsoft*") {
                        $status = (Test-NetConnection -Port 3389 -ComputerName $vmName).TcpTestSucceeded
                        if ($status -eq $false) {
                            $status = (Test-NetConnection (Get-VM $vm.name).guest.hostname).TcpTestSucceeded
                        }
                        Write-Host $status
                    }
                    else {
                        $status = (Test-NetConnection -Port 22 -ComputerName $vmName).TcpTestSucceeded
                        Write-Host $status
                    }
                    $clock++
                }
                until (($status -eq "True") -or ($clock -eq 5))
                Test-Connection $VmIPAddress
                # Alerta de estado de VM.
                if ($clock -eq 5) {
                    # Notificar por mail si la máquina no inicia tras 5 minutos.
                    $From = "";
                    $To = "";
                    #$Cc = "jgcasanova@sidertia.com";
                    $MailSubject = "Revisar VM: $vmName"
                    $MailBody = "La maquina virtual $VmName con IP $VmIPAddress no se ha iniciado tras 5 minutos desde su actualizacion.";
                    $Body = $MailBody | Out-String;
                    #$Attachment = (Get-ChildItem WO*.log).Fullname;
                    $SMTPServer = "smtprelay.";
                    $SMTPPort = "25";
                    Send-MailMessage -From $From -to $To -Subject $MailSubject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort #-UseSsl -Credential $MailCredentials -Attachments $Attachment -ErrorAction Stop -Cc $Cc
                    Write-Host "La maquina" $vm.Name "no se ha iniciado tras 5 minutos, se ha generado un E-Mail de alerta para analizarse" -ForegroundColor Red
                }
                elseif ($clock -lt 5) {
                    Write-Host La maquina $vm.Name esta encendida -ForegroundColor Blue
                }
            }
        }
    }
}