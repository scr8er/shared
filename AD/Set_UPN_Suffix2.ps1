Import-Module ActiveDirectory
$oldSuffix = "$domain.local"
$newSuffix = "$domain.com"
$server = "$DCserver"
Get-ADUser -filter * | ? {$_.UserPrincipalName -like "*@$domain.local"} | ForEach-Object {
$newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
$_ | Set-ADUser -server $server -UserPrincipalName $newUpn
}