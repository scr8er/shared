Function Get-AzRMRules {
param(
    [string]$RuleObject = $args[0])
Begin{
        # Start of the BEGIN block.
        Write-Verbose -Message "Entering the BEGIN block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
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

    } # End Begin block
Process{
        # Start of PROCESS block.
        Write-Verbose -Message "Entering the PROCESS block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
        if ($CheckModule)
            {
            $Lnumbers = Get-CellValue -path $ExcelPath -Coordinates A1:A5616 | select-string subnet
            foreach ($i in $Lnumbers)
                {
                $Coordinates = "A" + $i.linenumber + ":" + "B" + $i.linenumber
                Get-CellValue -path $ExcelPath -Coordinates $Coordinates
                }
            }
        } # End Process block
End{}
}