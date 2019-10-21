#Definir el contexto de subscripciones. get-azcontext -listavailable, select-azcontext
$tagName = "<Tagname>"
$resgroup = Get-AzResourceGroup | Where-Object { $_.Tags -ne $null }
foreach ($resourceg in $resgroup)
    {
    if ($resourceg.Tags.ContainsKey('$tagName'))
        {
            $resourceg.Tags.Remove('$tagName')
            $resourceg | Set-AzResourceGroup -Tags $resourceg.Tags
        }
    }
$res = Get-AzResource | Where-Object { $_.Tags -ne $null }
foreach ($resource in $res)
    {
    if ($resource.Tags.ContainsKey('$tagName'))
        {
            $resource.Tags.Remove('$tagName')
            $resource | Set-AzResource -Tags $resource.Tags
        }
    }