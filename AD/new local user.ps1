do {
$user = read-host "introduce UserName"
$Fullname = read-host "introduce nombre completo"
$Descripcion = read-host "introduce una descripción"
New-LocalUser -Name $user -FullName $Fullname -UserMayNotChangePassword  -Description $Descripcion -WhatIf
$continuar = read-host "¿Quieres crear más usuarios? s/n"
}
while ($continuar -eq "s")