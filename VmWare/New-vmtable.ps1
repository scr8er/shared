$i = 0
$TableName = "VMs-Outdated"
$table = New-Object System.Data.DataTable "$TableName"

#Define Columns
$col1 = New-Object system.Data.DataColumn VM_Name, ([string])
$col2 = New-Object system.Data.DataColumn HardwareVersion, ([string])
$col3 = New-Object system.Data.DataColumn NetAdapterType, ([string])
$col4 = New-Object system.Data.DataColumn Tools, ([string])
$col5 = New-Object system.Data.DataColumn OSFullName, ([string])

#Add the Columns
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)

$VmList = Get-VM * | Where-Object { ($_.HardwareVersion -ne "vmx-13") -or (Get-NetworkAdapter $_ | ? { $_.type -ne "Vmxnet3" }) -or (Get-VMGuest $_ | ? { $_.ToolsVersion -ne "10.2.1" }) -and (Get-VMGuest $_ | ? { $_.OSFullName -like "Microsoft*" }) }# | select -first 5
$total = $vmlist.count
foreach ($vm in $vmlist) {
    Write-Progress -Activity "Searching VMs" -Status "Progress: $i de $total" -PercentComplete ($i / $total * 100)
    $Type = Get-VM -name $vm.name | Get-NetworkAdapter | Select-Object type
    $tools = (Get-VM -name $vm.name | Get-VMGuest).ToolsVersion
    $OS = (Get-VM -name $vm.name | Get-VMGuest).OSFullName
    $row = $table.NewRow()
    $row.VM_Name = $vm.name
    $row.HardwareVersion = $vm.HardwareVersion
    $row.Tools = $Tools
    $row.OSFullName = $OS
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
    #$row.Tools = $Tools.ToolsVersion
    $table.Rows.Add($row)
    $row
    $i++
}
$table | Export-Csv .\VMs-Outdated.csv -Force