$TagName = "ExpirationDate"
$resgroup = Get-AzResourceGroup | Where-Object { $_.Tags -ne $null }
foreach ($resourceg in $resgroup)
    {
    if ($resourceg.Tags.ContainsKey($TagName))
        {
            if ($resourceg.Tags.$tagname.Length -gt 10)
            {
                $ExpDate = ($resourceg.Tags.$tagname).Split('T') | Select-Object -first 1
                $resourceg.Tags.Remove($TagName)
                $resourceg.Tags.Add($TagName,$ExpDate)
                $resourceg | Set-AzResourceGroup -Tags $resourceg.Tags
            }
        }
    }