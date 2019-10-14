## Troubleshooting ADFS.

Since server 2016 release, Microsoft has improved logging information and now it's easier to troubleshoot if you have previously enabled auditing and logging so, after your federation service farm installation, it's recommended to enable Adfs farm proper logging because it's disabled by default.

```PowerShell
Set-AdfsProperties -auditlevel verbose
Set-ADFSProperties -LogLevel Information, Errors, Verbose, Warnings, FailureAudits, SuccessAudits
Set-AdfsProperties -EnableIdPInitiatedSignonPage $true
auditpol.exe /set /subcategory:"Application generated" /failure:enable /success:enable

Install-Module -Name ADFSToolbox -Force
Import-Module ADFSToolbox -Force

Export-AdfsDiagnosticsFile
```

Also, Adfs team provide a toolbox to analyze general Adfs farm status, we just need to upload this generated diagnostics file.

```PowerShell
Install-Module -Name ADFSToolbox -Force
Import-Module ADFSToolbox -Force
Export-AdfsDiagnosticsFile
Start "https://adfshelp.microsoft.com/DiagnosticsAnalyzer/Analyze"
```

### Security tips
By default, federation service enable several endpoints for most common scenarios. It's also recommended to disable diagnostic or unused endpoints through application proxies, we'll be always able to check them internally if necessary.

```PowerShell
(Get-AdfsEndpoint | Where-Object {$_.Proxy -eq "True" -and $_.Enabled -eq "True"}).AddressPath

Set-AdfsEndpoint -TargetAddressPath <address path> -Proxy $false
```

It will depend on our organization requirements.

```PowerShell
PS C:\Windows\system32> (Get-AdfsEndpoint | Where-Object {$_.Proxy -eq "True" -and $_.Enabled -eq "True"}).AddressPath
/adfs/services/trust/mex
/adfs/ls/
/adfs/services/trust/2005/windowstransport
/adfs/services/trust/2005/certificatemixed
/adfs/services/trust/2005/certificatetransport
/adfs/services/trust/2005/usernamemixed
/adfs/services/trust/2005/issuedtokenmixedasymmetricbasic256
/adfs/services/trust/2005/issuedtokenmixedsymmetricbasic256
/adfs/services/trust/13/certificatemixed
/adfs/services/trust/13/usernamemixed
/adfs/services/trust/13/issuedtokenmixedasymmetricbasic256
/adfs/services/trust/13/issuedtokenmixedsymmetricbasic256
/FederationMetadata/2007-06/FederationMetadata.xml
/adfs/oauth2/
/EnrollmentServer/
/adfs/.well-known/openid-configuration
/adfs/discovery/keys
/.well-known/webfinger
/adfs/userinfo
```