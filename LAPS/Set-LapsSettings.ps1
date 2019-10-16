# Parameters
param (
    [string]$OU = $( Read-Host "OU where computers are located, example: OU=_Servers,DC=Domain,DC=local" ),
    [string]$AdminGroup = $( Read-Host "Password manager group" )
)
# Cargar el módulo para PowerShell
Import-Module AdmPwd.PS

# Facilitar permisos al grupo de máquinas para escribir la contraseña en el atributo.
Set-AdmPwdComputerSelfPermission -OrgUnit "$OU”

# Mostrar usuarios y grupos con permisos de lectura en los atributos personalizados AdmPwd.
Find-AdmPwdExtendedRights -identity "$OU" | Format-Table ExtendedRightHolders
Find-AdmPwdExtendedRights -identity:"$OU" | Format-Table ExtendedRightHolders

# Añadir grupos con permisos de lectura en los atributos personalizados de AdmPwd.
Set-AdmPwdReadPasswordPermission -OrgUnit "$OU" -AllowedPrincipals "$AdminGroup"
Set-AdmPwdResetPasswordPermission -OrgUnit "$OU" -AllowedPrincipals "$AdminGroup"