####################################################################
#Argumentos
#Param ([String]$Subscription.Name,[String]$GatewaySubnet,[String]$NetworkAddress)

# Constantes
$Subscription = Import-Csv -Path ".\ConfigureNewSubscription.csv" -Delimiter ";"
$CommsSubscription = "Production xS Production" #subscripción donde se encuentran las comunicaciones en Azure
$RGNet = "RG_NETWORK_PROD"
$RGNetNew = "RG_NETWORK_PRO"
$DebugMode = $true #Valores Aceptados $true o $false
$DebugColor = "Blue" #Texto debug resaltado en este color (no es válido ni rojo ni amarillo porque los usa el sistema)
$VMNicName = "aztestconnect01v" + (Get-Random(9999))
$VMDiskName = "aztestconnect01d" + (Get-Random(9999))
$VMCredential = Get-Credential -UserName "patrol" -Message "Password necesario para el usuario de la VM aztestconnect. Por defecto Patrol."
$MailCredentials = Get-Credential -Message "Introduce las credenciales para el envio del mail ()."


$WarningPreference = 'SilentlyContinue' #Oculta los mensajes de Warning
$LocationResource = "westeurope" #Localización de los recursos
$logfile = ".\" + $Subscription.TagTicket + "-{0:yyyy-MM-dd_HH.mm}.log"

# Ejecución
$start = Get-Date
Start-Transcript ($logFile -f ($start)) -Append
# Conexión a Azure (se desabilita cuando el modo depuración está activado)
If ( $true -ne $DebugMode ) {
    Connect-AzAccount
}
else {
    Write-Host "Modo Debug Activo" -ForegroundColor $DebugColor
}

# Autorización a la nueva subscripción a usar las Express Route
# Reemplaza los espacios del nombre de la subscripción por guiones para el identificador de la autorización
$authorizationName = $Subscription.Name -replace ' ', '-'
If ( $false -ne $DebugMode ) {
    Write-Host $authorizationName -ForegroundColor $DebugColor
}

# Selección de la subscripción de comunicaciones para gestionar express route
Select-AzSubscription -SubscriptionName $CommsSubscription

# Autoriza la subscripción en las ExpressRoutes.
foreach ($ER in Get-AzExpressRouteCircuit -ResourceGroupName $RGNet) { Add-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $ER -Name $authorizationName | Set-AzExpressRouteCircuit }
# Registra nombre, PeerId y AuthorizationKey para la creación de las conexiones.
$ExpressRoutes.clear()
$ExpressRoutes = foreach ($ExpressRoute in Get-AzExpressRouteCircuit -ResourceGroupName $RGNet) {
    [PSCustomObject]@{
        Name    = $ExpressRoute.name
        PeerId  = $ExpressRoute.id
        AuthKey = (Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $ExpressRoute -name $authorizationName).AuthorizationKey
    }
}

# Selección de la subscripción de para configurar los elementos de red
Select-AzSubscription -SubscriptionName $Subscription.Name
$ResourceName = "VN_" + $authorizationName.Substring(0, 14) + "_DEV"
$PublicIpName = "PIP_VNG_" + $authorizationName
$VirtualNetworkGatewayName = "VNG_" + $authorizationName
$SubnetName = "VLAN_" + $authorizationName.Substring(0, 13) + "_PRO"
If ( $false -ne $DebugMode ) {
    Write-Host $authorizationName -ForegroundColor $DebugColor
    Write-Host $publicIpName -ForegroundColor $DebugColor
    Write-Host $ResourceName -ForegroundColor $DebugColor
}

# Crea el grupo de recursos para los elementos de red.
New-AzResourceGroup -Name $RGNetNew -Location $LocationResource -Tag @{Owner = $Subscription.TagOwner; Environment = $Subscription.TagEnvironment; Service = $Subscription.TagService; CodigoProyecto = $Subscription.TagProyectCode; MaintenanceWindow = $Subscription.TagMaintenanceWindow; TicketID = $Subscription.TagTicket } -Force

# Crea los grupos de seguridad de red.
New-AzNetworkSecurityGroup -Name "NSG_GATEWAY-SN_PRO" -ResourceGroupName $RGNetNew -Location $locationResource
New-AzNetworkSecurityGroup -Name ($SubnetName.replace('VLAN', 'NSG')) -ResourceGroupName $RGNetNew -Location $locationResource

# Crea la virtual network.
$NewSubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $Subscription.GatewaySubnet
$VNet = New-AzVirtualNetwork -Name $ResourceName -ResourceGroupName $RGNetNew -Location $LocationResource -AddressPrefix $Subscription.NetworkAddress -Subnet $NewSubnet
$VNet | Set-AzVirtualNetwork

# Crea el Network Watcher de la VNET.
New-AzNetworkWatcher -Name "NetworkWatcher_$AuthorizationName" -ResourceGroupName $RGNetNew -Location $LocationResource

# Crea la IP Pública.
New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $RGNetNew -AllocationMethod Dynamic -Location $LocationResource

# Crear Subnet.
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RGNetNew -Name $ResourceName
Add-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork -AddressPrefix ($Subscription.GatewaySubnet.replace('.0/28', '.16/28')) | Set-AzVirtualNetwork

# Crear NIC de la VM.
New-AzNetworkInterface -Name $VmNicName -ResourceGroupName $RGNetNew -SubnetId (Get-AzVirtualNetworkSubnetConfig -name $SubnetName -VirtualNetwork (Get-AzVirtualNetwork -name $ResourceName -ResourceGroupName $RGNetNew)).Id -Location "$LocationResource"

# Definición de propiedades de la VM.
[Microsoft.Azure.Commands.Compute.Models.PSVirtualMachine] $AzVM = New-AzVMConfig -VMName "aztestconnect01" -VMSize "Standard_B1ls"
$AzVM | Add-AzVMNetworkInterface -Id (Get-AzNetworkInterface -name $VmNicName).id -ErrorAction Stop | Out-Null
$AzVM | Set-AzVMSourceImage -PublisherName "Oracle" -Offer "Oracle-Linux" -Skus "77" -Version latest -ErrorAction Stop | Out-Null
$AzVM | Set-AzVMOperatingSystem -Linux -ComputerName "aztestconnect01" -Credential $VMCredential -ErrorAction Stop | Out-Null
$AzVM | Set-AzVMOSDisk -name $VMDiskName -DiskSizeInGB 30 -StorageAccountType "Standard_LRS" -Caching ReadWrite -CreateOption FromImage -ErrorAction Stop | Out-Null

# Crear máquina virtual.
New-AzVM -Location "$LocationResource" -ResourceGroupName $RGNetNew -ErrorAction Stop -VM $AzVM

# Definición de componentes de la VNG.
# Crear un conjunto de configuraciones IP.
$VNGIpConfig = New-AzVirtualNetworkGatewayIpConfig -name VirtualNetworkGatewayIpConfig -SubnetId (Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RGNetNew -Name $ResourceName)).Id -PublicIpAddressId (Get-AzPublicIpAddress -name $PublicIpName).Id
# Crea la Virtual Network Gateway.
New-AzVirtualNetworkGateway -Name $VirtualNetworkGatewayName -ResourceGroupName $RGNetNew -GatewayType ExpressRoute -Location $LocationResource -GatewaySku "Standard" -IpConfigurations $VNGIpConfig

# Crear las conexiones de la Express Route.
$VNG = Get-AzVirtualNetworkGateway -ResourceGroupName RG_NETWORK_PRO
$ExpressRoutes | ForEach-Object { $ConnectionName = "CON_VNG-" + $_.name; New-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $RGNetNew -Location $LocationResource -ConnectionType ExpressRoute -AuthorizationKey $_.AuthKey -PeerId $_.PeerId -VirtualNetworkGateway1 $VNG }

# Asociar los grupos de seguridad de red a las subnets.
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RGNetNew -Name $ResourceName
$GatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $VirtualNetwork
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork
$nsg = Get-AzNetworkSecurityGroup -name "NSG_GATEWAY-SN_PRO"
$nsg2 = Get-AzNetworkSecurityGroup -name ($SubnetName.replace('VLAN', 'NSG'))
$GatewaySubnet.NetworkSecurityGroup = $nsg
$Subnet.NetworkSecurityGroup = $nsg2
Set-AzVirtualNetwork -VirtualNetwork $VirtualNetwork

# Auto Mail config.
$From = "";
$To = "";
#$Cc = "jgcasanova@sidertia.com";
$MailSubject = "Nueva subscripcion en Azure: " + $Subscription.name;
$MailBody = @($MailSubject, "`n", $Subscription.NetworkAddress, "`n", (Get-AzNetworkInterface -name $VmNicName).IPConfigurations.PrivateIpAddress, "", (Get-AzResource | Select-Object name, resourcetype, location | Format-Table *), "`n");
$Body = $MailBody | Out-String;
$Attachment = (Get-ChildItem WO*.log).Fullname;
$SMTPServer = "smtprelay";
$SMTPPort = "25";

# Registro de tiempo.
$Finish = Get-Date
New-TimeSpan -Start $Start -End $Finish

# Enviar mail al equipo, es necesario detener la transcripción antes de adjuntar el log o fallará al adjuntar el archivo por estar en uso.
Stop-Transcript
Send-MailMessage -From $From -to $To -Subject $MailSubject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $MailCredentials -Attachments $Attachment -ErrorAction Stop #-Cc $Cc

Remove-Item $Attachment
#Disconnect-AzAccount