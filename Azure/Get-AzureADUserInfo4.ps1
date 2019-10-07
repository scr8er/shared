$GroupName='VISIOONLINE'
$users = $result[$GroupName] | Select-Object -ExpandProperty userprincipalname
$ADGroupName = 'Cloud_Visio_Plan2'
foreach ($user in $users) { 
    $usertest = Get-ADuser -Filter {userPrincipalName -eq $user}
    Write-Host "Processing user {$user} - $($usertest.samaccountname)"
    Add-ADGroupMember -Identity $ADGroupName -Members $usertest
}