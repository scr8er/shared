param (
    [string]$UserName = $(Read-Host "UserName, `nExample: username@domain.onmicrosoft.com")
)
Connect-AzAccount -Credential (Get-Credential -UserName $UserName)