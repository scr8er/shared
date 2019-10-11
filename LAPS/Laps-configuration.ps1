Invoke-WebRequest "https://www.microsoft.com/en-us/download/confirmation.aspx?id=46899&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1" -OutFile c:\users\$env:USERNAME\Descargas
Import-Module AdmPwd.PS
Update-AdmPwdADSchema
Set-AdmPwdComputerSelfPermission -OrgUnit "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk”
Find-AdmPwdExtendedRights -identity "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk" | Format-Table ExtendedRightHolders
Find-AdmPwdExtendedRights -identity:"OU=SA Computers,DC=thesysadmins,DC=co,DC=uk" | Format-Table ExtendedRightHolders

Set-AdmPwdReadPasswordPermission -OrgUnit "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk " -AllowedPrincipals "LAPS"
Set-AdmPwdResetPasswordPermission -OrgUnit " OU=SA Computers,DC=thesysadmins,DC=co,DC=uk " -AllowedPrincipals "LAPS"

msiexec /q /i \\server\share\LAPS.x86.msi # CUSTOMADMINNAME=LocalAdmin
Test-Path -path C:\Program Files\LAPS\CSE\AdmPwd.dll
