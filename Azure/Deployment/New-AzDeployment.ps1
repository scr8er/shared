Function New-ResourceGroup {
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
        $ResourceGroupName = [PSCustomObject]@{
            value = $TargetRG
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
        $VngParamFile.parameters | Add-Member -name TargetRG -Value $ResourceGroupName -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name Resourcelocation -Value $Resourcelocation -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name sku -Value $sku -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name gatewayType -Value $gatewayType -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name existingVirtualNetworkName -Value $VnetName -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name newSubnetName -Value $newSubnetName -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name subnetAddressPrefix -Value $subnetAddressPrefix -MemberType NoteProperty -force
        $VngParamFile.parameters | Add-Member -name publicIpAddressId -Value $publicIpAddressId -MemberType NoteProperty -force
        $VngParamFile | ConvertTo-Json | Out-File $VngParamFilePath
    }
    Process {

        try {
            Write-Host "Iniciando despliegue de VNET en el grupo de recursos $TargetRG." -ForegroundColor Green
            <#& $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation $location -TemplateFilePath "$TemplatePath\VNET_Template.json" -ParametersFilePath "$TemplatePath\Vnet_CustomParameters.json" -Recurso "VirtualNetwork"#>
            New-AzResourceGroupDeployment -ResourceGroupName $TargetRG -TemplateFile "$TemplatePath\VNET_Template.json" -TemplateParameterFile "$TemplatePath\Vnet_CustomParameters.json" -Name $TargetRG
        }
        catch {
            Write-Host "Error al desplegar VNET" -ForegroundColor Red
            $error | Select-Object -first 1
            break
        }
        try {
            Write-Host "Iniciando despliegue de PIP en el grupo de recursos $TargetRG." -ForegroundColor Green
            <#& $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation westeurope -TemplateFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\PIP_Template.json" -ParametersFilePath $TemplatePath\Pip_CustomParameters.json -Recurso "PublicIPAddress"#>
            New-AzResourceGroupDeployment -ResourceGroupName $TargetRG -TemplateFile "$TemplatePath\Pip_Template.json" -TemplateParameterFile "$TemplatePath\Pip_CustomParameters.json" -Name $TargetRG
        }
        catch {
            Write-Host "Error al desplegar PIP" -ForegroundColor Red
            $error | Select-Object -first 1
            break
        }
        try {
            Write-Host "Iniciando despliegue de VNG en el grupo de recursos $TargetRG." -ForegroundColor Green
            <#& $DeployFilePath -subscription $TargetSubscription -ResourceGroupName $TargetRG -ResourceGroupLocation westeurope -TemplateFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\VNG_Template.json" -ParametersFilePath "C:\VSCode Workspace\Workspace #1\deployments\Templates\Vng_CustomParameters.json" -Recurso "ER-VirtualnetworkGateway"#>
            New-AzResourceGroupDeployment -ResourceGroupName $TargetRG -TemplateFile "$TemplatePath\Vng_Template.json" -TemplateParameterFile "$TemplatePath\Vng_CustomParameters.json" -Name $TargetRG
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