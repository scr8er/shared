# Enable audit
set-AdfsProperties -auditlevel verbose
Set-ADFSProperties -LogLevel Information, Errors, Verbose, Warnings, FailureAudits, SuccessAudits
Set-AdfsProperties -EnableIdPInitiatedSignonPage $true
auditpol.exe /set /subcategory:"Application generated" /failure:enable /success:enable

# Get ADFS diagnostics tool
Install-Module -Name ADFSToolbox -Force
Import-Module ADFSToolbox -Force

# Create diagnostics File
Export-AdfsDiagnosticsFile
start https://adfshelp.microsoft.com/DiagnosticsAnalyzer/Analyze