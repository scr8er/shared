param (
    [string]$username = $(Read-Host "UserName, `nExample: username@domain.onmicrosoft.com")
)
$username = ""
Connect-AzAccount -Credential (Get-Credential -UserName $username)