#check repository
Find-Module -Name VMware.PowerCLI

#Install Module
Install-Module -Name VMware.PowerCLI –Scope CurrentUser

#Import Module
Import-Module VMware.PowerCLI

#Generate credential file
New-VICredentialStoreItem -host $VCServer -user Domain\Username -password ****** -file $Path

#Vcenter connect
$EpiCredentials = Get-VICredentialStoreItem -File "c:\temp\VcredentialsEPI.xml"
Connect-VIServer $EpiCredentials.Host -User $EpiCredentials.user -Password $EpiCredentials.password