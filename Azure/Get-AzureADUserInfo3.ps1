$result = @{}
foreach ($row in $AllUserDetails) {
    foreach ($al in $row.assignedLicense) {
        if ($al.ServicePlanName) { 
            $sku = $al.ServicePlanName
            if($result.ContainsKey($sku)) {
                $currentUsers = $result[$sku]
                $newValue =  @($currentUsers) + @([pscustomobject]@{
                                                    userPrincipalName = $row.UserPrincipalName
                                                    DisplayName = $row.DisplayName
                                                }
                                                )
                $result[$sku] = $newValue
            }
            else {
                $result[$sku] = [pscustomobject]@{
                    userPrincipalName = $row.UserPrincipalName
                    DisplayName = $row.DisplayName
                }
            }
        }
    }
}
$result