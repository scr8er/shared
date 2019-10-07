$dns = "https://"
$server = "https://"
Get-OwaVirtualDirectory -server IMASDEX01 | Set-OwaVirtualDirectory -ExternalURL $dns/owa -InternalURL $server/owa
Get-ECPVirtualDirectory -server IMASDEX01 | Set-ECPVirtualDirectory -ExternalURL $dns/ecp -InternalURL $server/ecp
Get-ActiveSyncVirtualDirectory -server IMASDEX01 | Set-ActiveSyncVirtualDirectory -ActiveSyncServer $server/Microsoft-Server-ActiveSync -ExternalURL $dns/Microsoft-Server-ActiveSync -InternalURL $server/Microsoft-Server-ActiveSync
Get-OABVirtualDirectory -server IMASDEX01 | Set-OABVirtualDirectory -ExternalURL  $dns/OAB -InternalURL $server/OAB
Get-WebServicesVirtualDirectory -server IMASDEX01 | Set-WebServicesVirtualDirectory -ExternalURL  $dns/ews/exchange.asmx -InternalURL $server/ews/exchange.asmx
Get-PowerShellVirtualDirectory -server IMASDEX01 | Set-PowerShellVirtualDirectory -ExternalURL $null -InternalURL $server/powershell
Get-OutlookAnywhere -server IMASDEX01 | Set-OutlookAnywhere -ExternalHostName cloud1.imasdconsult.com -InternalHostName imasdex01.imasdconsult.local -InternalClientsRequireSsl $true -ExternalClientsRequireSsl $true -ExternalClientAuthenticationMethod Basic
Get-MAPIVirtualDirectory -server IMASDEX01 | Set-MAPIVirtualDirectory -ExternalURL $dns/mapi -InternalURL $server/mapi
Get-ClientAccessService -identity IMASDEX01 | Set-ClientAccessService -AutoDiscoverServiceInternalUri $server/Autodiscover/Autodiscover.xml