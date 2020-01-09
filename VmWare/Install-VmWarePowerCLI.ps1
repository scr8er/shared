#check repository
Find-Module -Name VMware.PowerCLI

#Install Module
Install-Module -Name VMware.PowerCLI –Scope CurrentUser

#Import Module
Import-Module VMware.PowerCLI

#Generate credential file
New-VICredentialStoreItem -host es1vcsaha01v.sp.securitasdirect.local -user SECURITASSP\jesus.gcasanova -Password -file "c:\temp\VcredentialsPRO.xml"

#Vcenter connect
Disconnect-VIServer -confirm:$false
$EpiCredentials = Get-VICredentialStoreItem -File ""
Connect-VIServer $EpiCredentials.Host -User $EpiCredentials.user -Password $EpiCredentials.password
$ProCredentials = Get-VICredentialStoreItem -File ""
Connect-VIServer $ProCredentials.Host -User $ProCredentials.user -Password $ProCredentials.password