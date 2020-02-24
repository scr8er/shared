# Constantes.
$Report = @();
#$RemoteAddresses = @("10.4.96.42", "10.2.96.42", "10.2.96.120");
If (Test-Path //ES1SISGES01V/user) {
    $SendReport = $false
}
else {
    $SendReport = $true
}

# Servicio Windows Management Instrumentation.
If (-not((Get-Service winmgmt).status -eq "Running")) {
    $report += "Servicio Iniciado: False"
}
else {
    $Report += "Servicio Iniciado: True"
}

# Windows Firewall y reglas de entrada y salida.
$IBRemoteAddress = (Get-NetFirewallRule -Direction Inbound | Get-NetFirewallAddressFilter).RemoteAddress
if ($IBRemoteAddress | Select-String "") {
    if ($IBRemoteAddress | Select-String "") {
        if ($IBRemoteAddress | Select-String "") {
            $Report += "Firewall Inbound Rule: True"
        }
        else {
            $Report += "Firewall Inbound Rule: False"
        }
    }
    else {
        $Report += "Firewall Inbound Rule: False"
    }
}
else {
    $Report += "Firewall Inbound Rule: False"
}
$OBRemoteAddress = (Get-NetFirewallRule -Direction outbound | Get-NetFirewallAddressFilter).RemoteAddress
if ($OBRemoteAddress | Select-String "") {
    if ($OBRemoteAddress | Select-String "") {
        if ($OBRemoteAddress | Select-String "") {
            $Report += "Firewall outbound Rule: True"
        }
        else {
            $Report += "Firewall outbound Rule: False"
        }
    }
    else {
        $Report += "Firewall outbound Rule: False"
    }
}
else {
    $Report += "Firewall outbound Rule: False"
}


# Usuario local administrador  "S-1-5-32-544").name | Select-String "user")) {
    If (-not (Get-LocalGroupMember -name (Get-LocalGroup -SID "S-1-5-32-544").name | Select-String "Security group")) {
        $Report += "DOMAIN\user Administrator: False"
    }
    else {
        $Report += "DOMAIN\user Administrator: True"
    }
}
else {
    $Report += "DOMAIN\user Administrator: True"
}
If ($SendReport) {
    $report | Out-File "C:\Report-$env:COMPUTERNAME.txt"
    # Configuración de Mail para el reporte.
    $From = "";
    $To = "";
    $MailSubject = "Forescout Reqs check: " + $env:COMPUTERNAME;
    $MailBody = @("Hostname:", $env:COMPUTERNAME, $report);
    $Body = $MailBody | Out-String;
    $Attachment = "C:\Report-$env:COMPUTERNAME.txt";
    $SMTPServer = "smtprelay";
    $SMTPPort = "25";
    Send-MailMessage -From $From -to $To -Subject $MailSubject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -ErrorAction Stop -Attachments $Attachment #-Cc $Cc -Attachments $Attachment -Credential $MailCredentials -UseSsl
    Remove-Item "C:\Report-$env:COMPUTERNAME.txt";
}
else {
    $report | Out-File //SERVER/user/report-$env:Computername.txt;
}
