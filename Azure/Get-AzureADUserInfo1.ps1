Import-Module azuread
Connect-AzureAD
$ExportPath = C:\ADINFO.json
$allusers = Get-AzureADUser -All $true
$AllUserDetails = foreach ($user in $allusers){ 
    $licenseDetails = Get-AzureADUserLicenseDetail -ObjectId $user.objectid | Select-Object -ExpandProperty ServicePlans
    $License = foreach ($licenseRow in $licenseDetails) {
        @{
            ServicePlanName = $licenseRow.ServicePlanName
            ProvisioningStatus = $licenseRow.ProvisioningStatus
            AppliesTo = $licenseRow.AppliesTo
            ServicePlanId = $licenseRow.ServicePlanId
        }
    }
    [pscustomObject]@{
        ObjectID = $user.ObjectID
        DisplayName = $user.DisplayName
        UserPrincipalName =$user.UserPrincipalName
        ObjectType = $user.ObjectType
        UserType = $user.UserType
        AccountEnabled =$user.AccountEnabled
        AssignedPlans = $user.AssignedPlans
        LastDirSyncTime = $user.LastDirSyncTime
        AssignedLicense =  $License
    }
}
$AllUserDetails | ConvertTo-Json -Depth 99 | Out-File $ExportPath