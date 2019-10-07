Function Get-AzRMRules {

# La función utiliza el Excel adjunto en el correo. Si no lo pones en C:\Scripts te pedirá ubicación.
# Necesita el módulo PsExcel, yo utilizo Visual Studio Code para trabajar con módulos en Powershell 6.2.1
# En ISE suele dar algún problema para instalar ciertos módulos.

Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
    $param1
    )
$CheckFiles = Test-path 'C:\Scripts\rbac rules.xlsx'
$CheckModule = (Get-installedModule).name | select-string PsExcel
        if (-not $CheckModule)
            {
            Write-Verbose -Message "PsExcel Module not found. Trying to locate and install"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-module PSExcel -SkipPublisherCheck -Confirm -Force
            }
        if (-not $CheckFiles)
                    {
                    Write-Verbose -Message "Excel File not found. Please provide a valid path.`n"
                    $ExcelPath = Read-Host
                    }
                else
                    {
                    $ExcelPath = "c:\scripts\rbac rules.xlsx"
                    }

$Lnumbers = Get-CellValue -path $ExcelPath -Coordinates A1:A5616 | select-string $param1
foreach ($i in $Lnumbers)              
    {
    $Coordinates = "A" + $i.linenumber + ":" + "B" + $i.linenumber
    Get-CellValue -path $ExcelPath -Coordinates $Coordinates
    }
}