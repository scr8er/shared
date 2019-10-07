Function VnetParams {
    <#
.SYNOPSIS
JSON param template example:
$json = '{
    "$schema":  "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion":  "1.0.0.0",
    "parameters":  {
                       "VnetName":  {
                                    "value":  ""
                                },
                       "location":  {
                                        "value":  ""
                                    },
                       "addressPrefix":  {
                                             "value":  ""
                                         },
                       "subnetName":  {
                                          "value":  ""
                                      },
                       "subnetAddressPrefix":  {
                                                   "value":  ""
                                               },
                       "enableDdosProtection":  {
                                                    "value":  false
                                                }
                   }
    }'
#>
    $VnetParamFilePath = "C:\VSCode Workspace\Workspace #1\Deployments\Templates\Parameter_Template.json"
    $VnetParamFile = [IO.File]::ReadAllText($VnetParamFilePath)
    $VnetParamFile = ConvertFrom-Json $VnetParamFile

    $location = [PSCustomObject]@{
        value = Read-Host "Introduce la localización"
    }
    $VnetParamFile.parameters | Add-Member -name Location -Value $location -MemberType NoteProperty -force

    $addressPrefix = [PSCustomObject]@{
        value = Read-Host "Introduce el prefijo 0.0.0.0/16"
    }
    $VnetParamFile.parameters | Add-Member -name addressPrefix -Value $addressPrefix -MemberType NoteProperty -force

    $subnetName = [PSCustomObject]@{
        value = Read-Host "Introduce el nombre de la subred"
    }
    $VnetParamFile.parameters | Add-Member -name subnetName -Value $subnetName -MemberType NoteProperty -force

    $subnetAddressPrefix = [PSCustomObject]@{
        value = Read-Host "Introduce el prefijo de la subred 0.0.0.0/24"
    }
    $VnetParamFile.parameters | Add-Member -name subnetAddressPrefix -Value $subnetAddressPrefix -MemberType NoteProperty -force

    $enableDdosProtection = [PSCustomObject]@{
        value = "false"
    }
    $VnetParamFile.parameters | Add-Member -name enableDdosProtection -Value $enableDdosProtection -MemberType NoteProperty -force

    $VnetParamFile | ConvertTo-Json | Out-File $VnetParamFilePath
}