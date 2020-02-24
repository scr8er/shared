# Constantes.
$Report = @();
$RemoteAddresses = @("IP1", "IP1", "IP1");

# Servicio Windows Management Instrumentation.
If (-not((Get-Service winmgmt).status -eq "Running")) {
    $report += (Start-Service winmgmt -Verbose -PassThru)
}
else {
    $Report += (Get-Service Winmgmt)
}

# Windows Firewall y reglas de entrada y salida.
if (-not (Get-NetFirewallRule -Name "Forescout Custom Rule Inbound")) {
    New-NetFirewallRule -Name "Forescout Custom Rule Inbound" -Enabled True -Action Allow -direction Inbound -DisplayName "Forescout Custom Rule Inbound" -Profile Domain, Private -RemoteAddress $RemoteAddresses -Verbose
    $Report += "`n`nRegla de firewall de entrada creada."
    $Report += (Get-NetFirewallRule -displayname "Forescout Custom Rule Inbound")
    $Report += (Get-NetFirewallRule -displayname "Forescout Custom Rule Inbound" | Get-NetFirewallAddressFilter)
}
else {
    $Report += "`n`nRegla de firewall Forescout Custom Rule Inbound ya existe, verificando las IPs origen..."
    $IBRemoteAddress = (Get-NetFirewallRule -Direction Inbound | Get-NetFirewallAddressFilter).RemoteAddress
    if ($IBRemoteAddress | Select-String "IP1") {
        $Report += "`nIP1"
        if ($IBRemoteAddress | Select-String "IP1") {
            $Report += "IP1"
            if ($IBRemoteAddress | Select-String "IP1") {
                $Report += "IP1`nIPs Correctas"
            }
            else {
                $report += "[ERROR] Revisar IPs origen, falta IP1"
            }
        }
        else {
            $report += "[ERROR] Revisar IPs origen, falta IP1"
        }
    }
    else {
        $report += "[ERROR] Revisar IPs origen, falta IP1"
    }

}
if (-not (Get-NetFirewallRule -Name "Forescout Custom Rule Outbound")) {
    New-NetFirewallRule -Name "Forescout Custom Rule Outbound" -Enabled True -Action Allow -direction OutBound -DisplayName "Forescout Custom Rule Outbound" -Profile Domain, Private -RemoteAddress $RemoteAddresses -Verbose
    $Report += "`nRegla de firewall de salida creada."
    $Report += (Get-NetFirewallRule -displayname "Forescout Custom Rule Outbound")
    $Report += (Get-NetFirewallRule -displayname "Forescout Custom Rule Outbound" | Get-NetFirewallAddressFilter)
}
else {
    $Report += "`nRegla de firewall Forescout Custom Rule Inbound ya existe, verificar las IPs origen..."
    $OBRemoteAddress = (Get-NetFirewallRule -Direction Outbound | Get-NetFirewallAddressFilter).RemoteAddress
    if ($OBRemoteAddress | Select-String "IP1") {
        $Report += "`nIP1"
        if ($OBRemoteAddress | Select-String "IP1") {
            $Report += "IP1"
            if ($OBRemoteAddress | Select-String "IP1") {
                $Report += "IP1`nIPs Correctas"
            }
            else {
                $report += "[ERROR] Revisar IPs origen, falta IP1"
            }
        }
        else {
            $report += "[ERROR] Revisar IPs origen, falta IP1"
        }
    }
    else {
        $report += "[ERROR] Revisar IPs origen, falta IP1"
    }
}

# Usuario local administrador Domain\user.
If (-not (Get-LocalGroupMember -name (Get-LocalGroup -SID "S-1-5-32-544").name | Select-String "user")) {
    If (-not (Get-LocalGroupMember -name (Get-LocalGroup -SID "S-1-5-32-544").name | Select-String "Security group")) {
        $Report += "`n[ERROR] El usuario Domain\user no tiene permiso de administrador."
    }
    else {
        $Report += "`nEl usuario Domain\user forma parte de los administradores locales del servidor."
    }
}
else {
    $Report += "`nEl usuario Domain\user forma parte de los administradores locales del servidor."
}
$Report
pause
# Configuración de Mail para el reporte.
#$From = "";
#$To = "";
#$MailSubject = "Forescout Reqs check: " + $env:COMPUTERNAME;
#$MailBody = @("Hostname:", $env:COMPUTERNAME, $report);
#$Body = $MailBody | Out-String;
#$Attachment = $null;
#$SMTPServer = "smtprelay";
#$SMTPPort = "25";
#
#Send-MailMessage -From $From -to $To -Subject $MailSubject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -ErrorAction Stop #-Cc $Cc -Attachments #$Attachment -Credential $MailCredentials -UseSsl#