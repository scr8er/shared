# Control de tiempo
$Start = Get-Date
#
Function Set-RPNames {

    # Añadir el identificador encontrado y su RPName al hash de comparación.
    $translate.add("'<identificador>'.","<rpname>")
    Foreach ($key in $presult.keys){
        $r = 0
        Foreach ($key2 in $translate.keys){
            if ($key -eq $key2){
                $result.add($Translate.$key2,$presult.$key)
                break
            }
            else{
                $r++
            }
            if ($r -eq $translate.count){
                $result.add($key,$presult.$key)
            }
        }
    }
    $result | ft name,value | out-string -Width 160 | out-file .\Get-ActiveRPNames_Summary.txt
}
#
Add-PSSnapin Microsoft.Adfs.Powershell
$End = Get-Date #FECHA FIN, POR DEFECTO FECHA/HORA ACTUAL
$After = Get-Date -date '19/06/2019 16:00:00' # MODIFICAR FECHA DE INICIO
Get-ADFSRelyingPartyTrust | select identifier | out-file .\RPS.txt

# FILTRO SEGURIDAD
$argsSec = @{}
$argsSec.Add("StartTime", $after)
$argsSec.Add("EndTime", $end)
$argsSec.Add("LogName", "Security")
$argsSec.Add("Id", "299")
$result = @{}
$presult = @{}
$translate = @{}
$i = 0
cls
Write-host "El resultado se guardará en $pwd\Get-ActiveRPNames_Summary.txt" -ForegroundColor Green
#Modificar Idioma para la consulta.
$orgCulture = Get-Culture
[System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"

$WinEvents = Get-WinEvent -FilterHashtable $argsSec # TEST | select -first 100
foreach ($WinEvent in $WinEvents){
    $WEFilter = ($winevent.Message -replace "A token was successfully issued for the relying party ", "").split(" ",2) | select -first 1
    $check = $presult.keys | select-string -Pattern $WEFilter
    Write-Progress -Activity "Searching Events" -Status "Progress:" -PercentComplete ($i/$WinEvents.count*100)
    if ($WEFilter -eq $null){
        ($WinEvent.message).Split("'") | select-object -skip 1 -First 1
    }
    Else{
        If ($check){
            $presult.$WEFilter = $presult.$WEFilter + 1
        }
        Else{
            $presult.add("$WEFilter",[int]1)
            $errorControl += $WEFilter
        }
    }
    $i++
}

#Restaurar Idioma tras la consulta.
[System.Threading.Thread]::CurrentThread.CurrentCulture = $orgCulture

remove-item .\RPS.txt
Set-RPNames

# Control de tiempo
$Finish = Get-Date
New-Timespan -Start $Start -End $Finish