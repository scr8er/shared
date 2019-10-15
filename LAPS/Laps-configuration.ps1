Invoke-WebRequest "https://www.microsoft.com/en-us/download/confirmation.aspx?id=46899&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1" -OutFile c:\users\$env:USERNAME\Descargas
Import-Module AdmPwd.PS
Update-AdmPwdADSchema

# Permisos al grupo de máquinas para escribir la contraseña en el atributo.
Set-AdmPwdComputerSelfPermission -OrgUnit "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk”

# Usuarios y grupos con permisos.
Find-AdmPwdExtendedRights -identity "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk" | Format-Table ExtendedRightHolders
Find-AdmPwdExtendedRights -identity:"OU=SA Computers,DC=thesysadmins,DC=co,DC=uk" | Format-Table ExtendedRightHolders

# Añadir usuarios y grupos para la administración.
Set-AdmPwdReadPasswordPermission -OrgUnit "OU=SA Computers,DC=thesysadmins,DC=co,DC=uk " -AllowedPrincipals "LAPS"
Set-AdmPwdResetPasswordPermission -OrgUnit " OU=SA Computers,DC=thesysadmins,DC=co,DC=uk " -AllowedPrincipals "LAPS"

msiexec /q /i \\server\share\LAPS.x86.msi # CUSTOMADMINNAME=LocalAdmin
Test-Path -path C:\Program Files\LAPS\CSE\AdmPwd.dll
Get-ChildItem ‘c:\program files\LAPS\CSE\Admpwd.dll’

# Get acl permission
Get-NetOU -FullData | Get-ObjectAcl -ResolveGUIDs |
Where-Object {
    ($_.ObjectType -like 'ms-Mcs-AdmPwd') -and
    ($_.ActiveDirectoryRights -match 'ReadProperty')
}

# increase laps log level
