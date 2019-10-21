# Descarga del software: https://www.microsoft.com/en-us/download/details.aspx?id=46899
Invoke-WebRequest "https://www.microsoft.com/en-us/download/confirmation.aspx?id=46899&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1" -OutFile "c:\users\$env:USERNAME\LAPS.x64.msi"

# Instalación automática del agente con los 4 componentes.
msiexec.exe /i c:\users\$env:UserName\LAPS.x64.msi ADDLOCAL=CSE, Management, Management.UI, Management.PS, Management.ADMX /quiet

# Cargar el módulo para PowerShell
Import-Module AdmPwd.PS

# Crear los atributos de directorio activo, recomendado desde el controlador con el rol de maestro de esquema. (netdom query fsmo)
Update-AdmPwdADSchema

# Modificar el nivel de registro.
New-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\{D76B9641-3288-4f75-942D-087DE603E3EA}' -name "ExtensionDebugLevel" -Value 2 -PropertyType DWORD

# Habilitar políticas de auditoría global y de auditoría de cambios.
auditpol /set /subcategory:"directory service changes" /success:enable

