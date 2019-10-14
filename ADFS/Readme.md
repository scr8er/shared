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