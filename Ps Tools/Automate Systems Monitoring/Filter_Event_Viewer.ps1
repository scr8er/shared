####################################################################################
# Event Viewer LOGS
####################################################################################
# FILTRO APLICACIÓN
$argsApp = @{}
$argsApp.Add("StartTime", ((Get-Date).AddDays(-365)))
$argsApp.Add("EndTime", (Get-Date))
$argsApp.Add("LogName", "Application")

# FILTRO SISTEMA
$argsSys = @{}
$argsSys.Add("StartTime", ((Get-Date).AddDays(-365)))
$argsSys.Add("EndTime", (Get-Date))
$argsSys.Add("LogName", "System")

Get-WinEvent -filterhashtable $argsApp | Where {$_.LevelDisplayName -ne "Información" -and $_.LevelDisplayName -ne "Information"} | Select MachineName,ProviderName,LevelDisplayName,Message,TimeCreated,LogName,Id
Get-WinEvent -filterhashtable $argsSys | Where {$_.LevelDisplayName -ne "Información" -and $_.LevelDisplayName -ne "Information"} | Select MachineName,ProviderName,LevelDisplayName,Message,TimeCreated,LogName,Id