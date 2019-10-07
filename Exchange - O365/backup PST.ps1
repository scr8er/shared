# La ejecución del comando set/get-MailboxExportRequest requiere asignación de rol mediante la siguiente ejecución
# New-ManagementRoleAssignment -role "Mailbox Import Export" -user administrador
# Una vez modificado es necesario reinciar la consola de administración de Exchange Server 2010.

#Se requieren permisos sobre la ubicación donde se exportarán los backup para el usuario Exchange Trusted Subsystem.
$PstPath = "\\$Server\$folder"

# Listado de usuarios para el backup.
$Usuarios = @("","")

foreach ($usuario in $Usuarios)
    {
    if (Test-Path -path $PstPath)
        {
        Write-Host "Iniciando exportación a PST del buzón de usuario $usuario." -ForegroundColor Green
        new-mailboxExportRequest -Mailbox $usuario -Filepath "$PstPath\$usuario.pst"
        }
        else
        {
        Write-Host "No se ha detectado la unidad compartida" -ForegroundColor Red
        }
    }

# Revisar el estado de las exportaciones.
Get-MailboxExportRequest | Format-Table mailbox, status
Get-MailboxExportRequest | Where-Object { $_.status -eq "Completed" } | Format-Table mailbox, status