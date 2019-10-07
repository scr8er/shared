# LicenseSKU Csv File 
<#
SKUID;SKUName
BI_AZURE_P0;Power BI (free)
BI_AZURE_P2;Power BI Pro
WIN10_PRO_ENT_SUB;Windows 10 Enterprise E5
INTUNE_O365;Intune
VISIOONLINE;Visio Online Plan 2
POWERFLOWSFREE;PowerApps and Logic Flows
PROJECTWORKMANAGEMENT;Office 365 Enterprise E3
EXCHANGE_S_ENTERPRISE;Office 365 Enterprise E3
BPOS_S_TODO_2;Office 365 Enterprise E3
FORMS_PLAN_E3;Office 365 Enterprise E3
YAMMER_ENTERPRISE;Office 365 Enterprise E3
MCOSTANDARD;Office 365 Enterprise E3
FLOW_O365_P2;Office 365 Enterprise E3
SWAY;Office 365 Enterprise E3
TEAMS1;Office 365 Enterprise E3
OFFICESUBSCRIPTION;Office 365 Enterprise E3
STREAM_O365_E3;Office 365 Enterprise E3
Deskless;Office 365 Enterprise E3
POWERAPPS_O365_P2;Office 365 Enterprise E3
Microsoft Stream;Microsoft Stream Trial
DYN365_ENTERPRISE_P1;Dynamics 365 Customer Engagement Plan
POWERAPPS_P2_VIRAL;Microsoft PowerApps Plan 2 Trial (d5368ca3-357e-4acb-9c21-8495fb025d1f)
FLOW_P2_VIRAL_REAL;Microsoft PowerApps Plan 2 Trial (d20bfa21-e9ae-43fc-93c2-20783f0840c3)
FLOW_P2_VIRAL;Microsoft Flow Free (50e68c76-46c6-4674-81f9-75456511b170)
DYN365_CDS_VIRAL;Microsoft Flow Free (17ab22cd-a0b3-4536-910a-cb6eb12696c0)
EXCHANGE_S_STANDARD;Exchange Online (Plan 1)
AAD_PREMIUM;Enterprise Mobility + Security E3
ADALLOM_S_DISCOVERY;Enterprise Mobility + Security E3
RMS_S_PREMIUM;Enterprise Mobility + Security E3
MFA_PREMIUM;Enterprise Mobility + Security E3
INTUNE_A;Enterprise Mobility + Security E3
Dynamics_365_Hiring_Free_PLAN;Dynamics 365 for Talent
DYN365_CDS_DYN_APPS;Dynamics 365 for Talent
POWERAPPS_DYN_APPS;Dynamics 365 for Talent
Dynamics_365_for_HCM_Trial;Dynamics 365 for Talent
FLOW_DYN_APPS;Dynamics 365 for Talent
Dynamics_365_Onboarding_Free_PLAN;Dynamics 365 for Talent
DYN365_BUSINESS_Marketing;Dynamics 365 for Marketing
MCOMEETADV;Audio Conferencing
SPZA;AppConnect
AAD_BASIC;Azure Active Directory Basic
POWERVIDEOSFREE;PowerApps and Logic Flows
POWERFLOWSFREE;PowerApps and Logic Flows
POWERAPPSFREE;PowerApps and Logic Flows
PROJECT_PROFESSIONAL;Project Online Professional
SHAREPOINT_PROJECT;Project Online Professional
PROJECT_CLIENT_SUBSCRIPTION;Project Online Professional #>

Import-Module azuread
Connect-AzureAD
$currentDate = Get-Date -Format yyyyMMdd_HHmmss
$LicenseSKU = Import-Csv -Path .\AZADResources1.ps1
$JSONExportFileName = 'users_licenses_{0}.json' -f $currentDate
$ExportPath=  Join-Path .\ -ChildPath $JSONExportFileName 
$counter = 1
$allusers = Get-AzureADUser -All $true
$AllUserDetails = foreach ($user in $allusers){ 
    $percentComplete = $counter / $allusers.count * 100
    $Activity = @{
        Activity = "Processing user {$counter} of $($allusers.count)" 
        Status = "Processing user {$($User.DisplayName)}" 
        PercentComplete=  $percentComplete 
        CurrentOperation = 'Getting user license detail from AzureAD'
    }
    Write-Progress  @Activity

    #get license details
    $licenseDetails = Get-AzureADUserLicenseDetail -ObjectId $user.objectid | Select-Object -ExpandProperty ServicePlans
    $License = foreach ($licenseRow in $licenseDetails) {
        @{
            ServicePlanName = $licenseRow.ServicePlanName
            FullServicePlanName = $LicenseSKU | Where-Object {$PSItem.SKUID -eq $licenseRow.ServicePlanName} | Select-Object -ExpandProperty SKUName
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
    $counter++
} 
$AllUserDetails | ConvertTo-Json -Depth 99 | Out-File $ExportPath