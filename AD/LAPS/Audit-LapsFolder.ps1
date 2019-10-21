$SecureLaps = [PSCustomObject]@{
    FileHash = Get-FileHash -Path "C:\program files\LAPS\CSE\AdmPwd.dll"
    AuthSign   = Get-AuthenticodeSignature -FilePath "C:\program files\LAPS\CSE\AdmPwd.dll"
}
$SecureLaps | ConvertTo-Json | Out-File "C:\Program Files\Laps\Integrity.json"