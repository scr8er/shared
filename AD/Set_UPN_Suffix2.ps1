Import-Module ActiveDirectory
$oldSuffix = "$server.local"
$newSuffix = "$server.com"
$server = "$DCserver"
Get-ADUser -filter * | ? {$_.UserPrincipalName -like "*@$server.local"} | ForEach-Object {
$newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
$_ | Set-ADUser -server $server -UserPrincipalName $newUpn
}