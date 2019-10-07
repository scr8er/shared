Function MenuInicial {
    do {
        Write-Host "`n`n================ AZ Menu ================"

        Write-Host "0) Iniciar sesión en Azure" -ForegroundColor Green
        Write-Host "1) Contexto de azure" -ForegroundColor Green
        Write-Host "2) Crear grupo de recursos" -ForegroundColor Green
        Write-Host "3) Crear Vnet-PIP-VNG" -ForegroundColor Green
        Write-Host "9) Cerrar Sesión" -ForegroundColor Green
        Write-Host "X) Salir" -ForegroundColor Green
        $input = Read-Host "`nIntroduce una opción"
        switch ($input) {
            '0' {
                Logout-AzAccount
                New-AzLogin
            }
            '1' {
                Set-AzureContext
            }
            '2' {
                $NewResourceGroupName = Read-Host "Introduce un nombre para el nuevo grupo de recursos. RG_****_???"
                New-VerisureResourceGroup -NewResourceGroupName $NewResourceGroupName
            }
            '3' {
                New-SubsResources -DeployFilePath 'C:\VSCode Workspace\Workspace #1\Deployments\deploy.ps1' -TemplatePath 'C:\VSCode Workspace\Workspace #1\Deployments\Templates'
            }
            '9' {
                Logout-AzAccount
            }
            'X' {
                break
            }
        }
    }
    while ($input -ne "X")
}
Function New-AzLogin {
    begin {
        $credential = Get-Credential -username "adm_jesus.gcasanova@verisure.onmicrosoft.com" -Message "Credenciales Azure PS Login"
    }
    Process {
        try {
            Connect-AzAccount -Credential $credential -ErrorAction Stop
        }
        catch {
            Clear-Host
            Write-Host "Error al iniciar sesión." -ForegroundColor Red
            break
        }
    }
    End {
        Clear-Host
        Write-Host "Sesión iniciada en Azure." -ForegroundColor Green
    }
}
Function Set-AzureContext {
    begin {
        [Int]$startcount = (Get-AzContext -listavailable).count
        $AzContextTable.Clear()
        $AzContextTable = @{ }
        Get-AzContext -listavailable | Select-Object -Property @{N = 'SubsId'; E = { $script:startcount++; $startcount } }, Name | ForEach-Object { $AzContextTable.add($_.SubsId, $_.Name); [Int] $startcount-- }
        Clear-Host
        $AzContextTable
    }
    Process {
        [Int]$AzContextSelection = Read-Host "`n`nSelecciona la subscripción sobre la que trabajar."
        try {
            Select-AzContext -Name $AzContextTable.$AzContextSelection -ErrorAction stop
        }
        catch {
            Write-Host "Error en la selección del contexto de azure. Confirmar el contexto actual antes de continuar" -ForegroundColor Red
            $input = X
        }
    }
    End {
        Write-Host "Contexto modificado correctamente." -ForegroundColor Green
    }
}
Function New-VerisureResourceGroup {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [String] [ValidatePattern("RG_\w{3,15}_[A-Z][A-Z][A-Z]")] $NewResourceGroupName,
        [Parameter(Mandatory = $true)] [String] [ValidateSet("westeurope", "northeurope")] $location
    )

    begin {
        $taghash = @{
            'MaintenanceWindow' = Read-Host "`nIntroduce el valor para MaintenanceWindow en formato ##h-##h"
            'Owner'             = Read-Host "`nArquitectura, BI, BP Field, BP Headquarters, BP MKT & Sales, BP Monitoring, Entornos y Despliegues, Integracion, It BBDD, It Communications, It Operaciones Support Center, It Security, It Systems Linux, It Systems Monitoring, It Systems Windows, Reception, Telephony, Web`nIntroduce el valor para Owner"
            'Environment'       = Read-Host "`nExperimentation, Production, Development, EPI`nIntroduce el valor para Environment"
            'Service'           = Read-Host "`nIntroduce el valor para servicio"
            'TicketID'          = Read-Host "`nIntroduce el valor para TicketID en formato WO1234567891234 (WO + 13 dígitos)"
            'CodigoProyecto'    = Read-Host "`nIntroduce el Código de proyecto"
        }
    }
    process {
        try {
            New-AzResourceGroup -name $NewResourceGroupName -tag $taghash -location $location -ErrorAction Stop
        }
        catch {
            Clear-Host
            $Error1 = $_.Exception.Message
            $Error2 = $_.Exception.ItemName
            Write-Host "Error al crear el grupo de recursos $NewResourceGroupName en $location.`n$error1`n$error2" -ForegroundColor Red
            break
        }
    }
    End {
        Clear-Host
        Write-Host "Se ha creado el grupo de recursos $NewResourceGroupName en $location." -ForegroundColor Green
    }
}
Function New-SubscriptionResources {
    param(
        [Parameter(Mandatory = $true)] [String] $DeployFilePath,
        [Parameter(Mandatory = $true)] [String] $TemplatePath
    )
    Begin {
        $TargetSubscription = (Get-AzContext).Subscription.Id
        [string]$InputRG = Read-Host "Introduce el nombre del grupo de recursos, si no existe, se creará.`n"
        $CheckRG = Get-AzResourceGroup -name $InputRG
        if ($CheckRG) {
            Write-Host "El Grupo ya existe, los recursos se desplegarán sobre $InputRG`n"
            [string]$location = $CheckRG.location
            $TargetRG = $InputRG
        }
        else {
            Write-Host "El grupo de recursos no existe. Creando el grupo de recursos $InputRG`n"
            [string]$location = Read-Host "Introduce la localizacion del grupo de recursos (westeurope o northeurope).`n"
            New-VerisureResourceGroup -NewResourceGroupName $InputRG -location $location
            $TargetRG = $InputRG
        }
        $template = '{
            "$schema":  "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
            "contentVersion":  "1.0.0.0",
            "parameters": { }
        }';

        $VnetParamFilePath = $TemplatePath + "\Vnet_CustomParameters.json"
        $VnetName = [PSCustomObject]@{
            value = Read-Host "Introduce el nombre de la VNET"
        }
        $Resourcelocation = [PSCustomObject]@{
            value = $location
        }
        $addressPrefix = [PSCustomObject]@{
            value = Read-Host "Introduce el prefijo 0.0.0.0/16"
        }
        $subnetName = [PSCustomObject]@{
            value = Read-Host "Introduce el nombre de la subred"
        }
        $subnetAddressPrefix = [PSCustomObject]@{
            value = Read-Host "Introduce el prefijo de la subred 0.0.0.0/24"
        }
        $enableDdosProtection = [PSCustomObject]@{
            value = [bool]$false
        }
        $VnetParamFile = ConvertFrom-Json $template
        $VnetParamFile.parameters | Add-Member -name VnetName -Value $VnetName -MemberType NoteProperty -force
        $VnetParamFile.parameters | Add-Member -name location -Value $Resourcelocation -MemberType NoteProperty -force
        $VnetParamFile.parameters | Add-Member -name addressPrefix -Value $addressPrefix -MemberType NoteProperty -force
        $VnetParamFile.parameters | Add-Member -name subnetName -Value $subnetName -MemberType NoteProperty -force
        $VnetParamFile.parameters | Add-Member -name subnetAddressPrefix -Value $subnetAddressPrefix -MemberType NoteProperty -force
        $VnetParamFile.parameters | Add-Member -name enableDdosProtection -Value $enableDdosProtection -MemberType NoteProperty -force
        $VnetParamFile | ConvertTo-Json | Out-File $VnetParamFilePath

        $PipParamFilePath = $TemplatePath + "\Pip_CustomParameters.json"
        $PIPname = [PSCustomObject]@{
            value = Read-Host "Introduce el nombre de la PIP"
        }
        $sku = [PSCustomObject]@{
            value = "Basic"
        }
        $publicIPAllocationMethod = [PSCustomObject]@{
            value = "Dynamic"
        }
        $idleTimeoutInMinutes = [PSCustomObject]@{
            value = 4
        }
        $publicIpAddressVersion = [PSCustomObject]@{
            value = "Ipv4"
        }
        $PipParamFile = ConvertFrom-Json $template
        $PipParamFile.parameters | Add-Member -name PIPname -Value $PIPname -MemberType NoteProperty -force
        $PipParamFile.parameters | Add-Member -name Resourcelocation -Value $Resourcelocation -MemberType NoteProperty -force
        $PipParamFile.parameters | Add-Member -name sku -Value $sku -MemberType NoteProperty -force
        $PipParamFile.parameters | Add-Member -name publicIPAllocationMethod -Value $publicIPAllocationMethod -MemberType NoteProperty -force
        $PipParamFile.parameters | Add-Member -name idleTimeoutInMinutes -Value $idleTimeoutInMinutes -MemberType NoteProperty -force
        $PipParamFile.parameters | Add-Member -name publicIpAddressVersion -Value $publicIpAddressVersion -MemberType NoteProperty -force
        $PipParamFile | ConvertTo-Json | Out-File $PipParamFilePath

        $VngParamFilePath = $TemplatePath + "\Vng_CustomParameters.json"
        $VNGname = [PSCustomObject]@{
            value = Read-Host "Introduce el nombre de la VNG"
        }
        $sku = [PSCustomObject]@{
            value = "Standard"
        }
        $gatewayType = [PSCustomObject]@{
            value = "ExpressRoute"
        }
        $NewSubnetName = [PSCustomObject]@{
            value = "GatewaySubnet"
        }
        $subnetAddressPrefix = [PSCustomObject]@{
            value = Read-Host "Introduce el prefijo 10.0.1.0/24"
        }
        [string]$pipnamevalue = $pipname.value
        $publicIpAddressId = [PSCustomObject]@{
            value = "/subscriptions/$TargetSubscription/resourceGroups/$targetRG/providers/Microsoft.Network/publicIPAddresses/$PipNamevalue"
        }
        $VngParamFile = ConvertFrom-Json $template
        $VngParamFile.parameters | Add-Member -name VNGname -Value $VNGname -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -nameResourceGroupName -Value $TargetRG -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name Resourcelocation -Value $Resourcelocation -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name sku -Value $sku -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name gatewayType -Value $gatewayType -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name existingVirtualNetworkName -Value $VnetName -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name newSubnetName -Value $newSubnetName -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name subnetAddressPrefix -Value $subnetAddressPrefix -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name publicIpAddressId -Value $publicIpAddressId -MemberType NoteProperty -force
        $VngParamFile | ConvertTo-Json | Out-File $VngParamFilePath
        Get-Content $VngParamFilePath
        Get-Content $PipParamFilePath
        Get-Content $VnetParamFilePath
    }
    Process {

        try {
            Write-Host "Iniciando despliegue de VNET en el grupo de recursos $TargetRG." -ForegroundColor Green
            & $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation $location -TemplateFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\VNET_Template.json" -ParametersFilePath "$TemplatePath\Vnet_CustomParameters.json" -Recurso "VirtualNetwork"
        }
        catch {
            Write-Host "Error al desplegar VNET" -ForegroundColor Red
            $error | Select-Object -first 1
            break
        }
        try {
            Write-Host "Iniciando despliegue de PIP en el grupo de recursos $TargetRG." -ForegroundColor Green
            & $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation westeurope -TemplateFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\PIP_Template.json" -ParametersFilePath $TemplatePath\Pip_CustomParameters.json -Recurso "PublicIPAddress"
        }
        catch {
            Write-Host "Error al desplegar PIP" -ForegroundColor Red
            $error | Select-Object -first 1
            break
        }
        try {
            Write-Host "Iniciando despliegue de VNG en el grupo de recursos $TargetRG." -ForegroundColor Green
            & $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation westeurope -TemplateFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\VNG_Template.json" -ParametersFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\Vng_CustomParameters.json" -Recurso "ER-VirtualnetworkGateway"
        }
        catch {
            Write-Host "Error al desplegar VNG" -ForegroundColor Red
            $error | Select-Object -first 1
            break
        }
    }
    End {
        Write-Host "Los recursos se desplegaron correctamente." -ForegroundColor Green
    }
}