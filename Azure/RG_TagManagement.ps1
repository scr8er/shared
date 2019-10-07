#Definir el contexto de subscripciones. get-azcontext -listavailable, select-azcontext
$tagName = "<Tagname>"
$resgroup = Get-AzResourceGroup | Where-Object { $_.Tags -ne $null }
foreach ($resourceg in $resgroup)
    {
    if ($resourceg.Tags.ContainsKey('$tagname'))
        {
            $resourceg.Tags.Remove('$tagname')
            $resourceg | Set-AzResourceGroup -Tags $resourceg.Tags
        }
    }
$res = Get-AzResource | Where-Object { $_.Tags -ne $null }
foreach ($resource in $res)
    {
    if ($resource.Tags.ContainsKey('$tagname'))
        {
            $resource.Tags.Remove('$tagname')
            $resource | Set-AzResource -Tags $resource.Tags
        }
    }