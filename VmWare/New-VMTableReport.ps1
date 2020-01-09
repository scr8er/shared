# Definición de variables iniciales y contadores.
[string]$TableName = "VMs-Outdated";
$table = New-Object System.Data.DataTable "$TableName";
$Excel = Import-Excel 'C:\Users\jgcasanova\Desktop\Listado VMs\Listado_VMs.xlsx'
$Excel2 = Import-Excel 'C:\Users\jgcasanova\Desktop\Listado VMs\Lista_Global_Actual_2020_v1.xlsx';

#Definición de columnas
$col1 = New-Object system.Data.DataColumn VM_Name, ([string]);
$col2 = New-Object system.Data.DataColumn HardwareVersion, ([string]);
$col3 = New-Object system.Data.DataColumn NetAdapterType, ([string]);
$col4 = New-Object system.Data.DataColumn Tools, ([string]);
$col5 = New-Object system.Data.DataColumn OSFullName, ([string]);
$col6 = New-Object system.Data.DataColumn Environment, ([string]);
$col7 = New-Object system.Data.DataColumn ESX, ([string]);
$col8 = New-Object system.Data.DataColumn Version_ESX, ([string]);
$col9 = New-Object system.Data.DataColumn Status, ([string]);
$col10 = New-Object system.Data.DataColumn Nueva, ([string]);
$col11 = New-Object system.Data.DataColumn Ciclo, ([string]);
$col12 = New-Object system.Data.DataColumn Servicio, ([string]);

#Añadir columnas
$table.columns.add($col1);
$table.columns.add($col2);
$table.columns.add($col3);
$table.columns.add($col4);
$table.columns.add($col5);
$table.columns.add($col6);
$table.columns.add($col7);
$table.columns.add($col8);
$table.columns.add($col9);
$table.columns.add($col10);
$table.columns.add($col11);
$table.columns.add($col12);

# Conexión al vCenter
$vCenterCredentials = @("c:\temp\.xml", "c:\temp\.xml");
foreach ($vCenterCredentialsFile in $vCenterCredentials) {
    [int]$i = 0;
    $vCenterConnection = Get-VICredentialStoreItem -File $vCenterCredentialsFile;
    Connect-VIServer $vCenterConnection.Host -User $vCenterConnection.user -Password $vCenterConnection.password;

    # Ámbito del VCenter.
    [String]$vcenter = (Get-VIAccount).server.name | Select-Object -Unique;
    if ($vcenter -eq "...local") {
        [string]$environment = ""
    }
    if ($vcenter -eq "...local") {
        [string]$environment = ""
    }

    # Obtener listado de máquinas virtuales.
    $VmList = Get-VM * | Where-Object { ($_.HardwareVersion -ne "vmx-13") -or (Get-NetworkAdapter $_ | Where-Object { $_.type -ne "Vmxnet3" }) } <#-or (Get-VMGuest $_ | Where-Object { $_.ToolsVersion -ne "10.2.1" }) } -and (Get-VMGuest $_ | ? { $_.OSFullName -like "Microsoft*" }) } | Select-Object -first 25 #>
    $total = $VmList.count;

    # Inicio del bucle
    foreach ($vm in $VmList) {
        # Reinicio de fila y contadores.
        Clear-Variable row;
        $i++;
        # Write-Progress -Activity "Searching VMs" -Status "Progress: $i de $total" -PercentComplete ($i / $total * 100)
        Write-Host "$i de $total" -ForegroundColor Yellow;

        # Registro de información
        $Type = Get-VM -name $vm.name | Get-NetworkAdapter | Select-Object type;
        $tools = (Get-VM -name $vm.name | Get-VMGuest).ToolsVersion;
        $OS = (Get-VM -name $vm.name | Get-VMGuest).OSFullName;
        $row = $table.NewRow();
        $row.VM_Name = $vm.name;
        $row.HardwareVersion = $vm.HardwareVersion;
        if ($type.count -eq 4) {
            $row.NetAdapterType = [string]$type.Type[0] + "," + [string]$type.type[1] + "," + [string]$type.type[2] + "," + [string]$type.type[3]
        }
        if ($type.count -eq 3) {
            $row.NetAdapterType = [string]$type.Type[0] + "," + [string]$type.type[1] + "," + [string]$type.type[2]
        }
        if ($type.count -eq 2) {
            $row.NetAdapterType = [string]$type.Type[0] + "," + [string]$type.type[1]
        }
        if ($null -eq $type.count) {
            $row.NetAdapterType = $Type.type[0]
        }
        $row.Tools = $Tools;
        $row.OSFullName = $OS;
        $row.Environment = $Environment;
        $row.ESX = $vm.VMHost.name;
        $row.Version_ESX = (Get-View -ViewType HostSystem -Property Name, Config.Product | Where-Object { $_.name -eq $vm.VMHost.name }).Config.Product.Fullname
        $row.Status = $vm.PowerState;
        if ($excel.VM_Name | Select-String $vm.name) {
            [String]$row.nueva = "No"
        }
        else {
            [String]$row.nueva = "Si"
        }

        if ($excel2 | where-object { $_.ciclo -eq "OK (real)" } | Select-Object maquina | Select-String $vm.name) {
            [String]$row.ciclo = ($excel2 | Where-Object { $_.maquina -eq $vm.name })."dia ", ($excel2 | Where-Object { $_.maquina -eq $vm.name }).semana
        }
        else {
            [String]$row.ciclo = "No"
        }

        if ($excel2 | Where-Object { $_.DEPARTAMENTO -ne $null }) {
            [String]$row.Servicio = ($excel2 | Where-Object { $_.maquina -eq $vm.name }).DEPARTAMENTO
        }

        # Crear nueva fila con los datos de la VM.
        $table.Rows.Add($row);

        # Mostrar info de cada VM
        $row;
    }

    Disconnect-VIServer -confirm:$false -Verbose
}

# Exportación de datos.
$table | Export-Csv '.csv' -Force;