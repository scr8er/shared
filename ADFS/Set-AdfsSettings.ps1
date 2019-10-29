# Parameters
param (
    [string]$gmsa = $( Read-Host "Group Managed Service Account Name" )
)

# Install AD module.
Install-WindowsFeature RSAT-AD-PowerShell

# Check allowed computer accounts
$check = (Get-ADServiceAccount $gmsa -Properties PrincipalsAllowedToRetrieveManagedPassword).PrincipalsAllowedToRetrieveManagedPassword | Select-String $env:COMPUTERNAME
If ($check) {
    Write-Host "$env:COMPUTERNAME allowed to retrieve gMSA password"
}
else {
    # Add new host with managed password retrieve permission.
    Set-ADServiceAccount $gmsa -PrincipalsAllowedToRetrieveManagedPassword (Get-ADComputer $env:COMPUTERNAME).DistinguishedName
    # Install gMSa
    Get-ADServiceAccount -filter { name -eq $gmsa } | Install-ADServiceAccount
}
Test-ADServiceAccount $gmsa
Read-Host "Pulsa cualquier tecla para continuar"

# Enable audit
Set-AdfsProperties -auditlevel verbose
Set-AdfsProperties -LogLevel Information, Errors, Verbose, Warnings, FailureAudits, SuccessAudits
Set-AdfsProperties -EnableIdPInitiatedSignonPage $true
auditpol.exe /set /subcategory:"Application generated" /failure:enable /success:enable

# Get ADFS diagnostics tool
Install-Module -Name ADFSToolbox -Force
Import-Module ADFSToolbox -Force

# Disable Extranet Endpoints
Set-AdfsProperties –EnableIdpInitiatedSignonPage $False

Set-AdfsEndpoint -TargetAddressPath `
    /adfs/services/trust/2005/windowstransport -Proxy $false

Set-AdfsEndpoint -TargetAddressPath `
    /adfs/services/trust/13/windowstransport -Proxy $false

# Create diagnostics File
Export-AdfsDiagnosticsFile
start-process https://adfshelp.microsoft.com/DiagnosticsAnalyzer/Analyze