# LAPS Utilities

Client script installation.
```Powershell
.\install-clientlaps.ps1  
```

Test previous or succeeded installations.
```Powershell
test-path "C:\Program Files\LAPS\CSE\Admpwd.dll"
```
Server install
```Powershell
msiexec.exe /i $MsiPath ADDLOCAL=CSE,Management,Management.UI,Management.PS,Management.ADMX /quiet
```
Client install
```Powershell
msiexec.exe /q /i $MsiPath CUSTOMADMINNAME=$AdminUser 
```
Rename Built-in Admin account.
```Powershell
$BuiltinAdmin  = (gwmi -query "Select * From Win32_UserAccount Where LocalAccount = TRUE AND SID LIKE 'S-1-5%-500'")
$BuiltinAdmin.rename("$name")
```
