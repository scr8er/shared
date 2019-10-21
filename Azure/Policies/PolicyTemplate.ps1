# Parameters
param (
    [string]$PolicyName = $( Read-Host "Enter policy name"),
    [string]$PolicyDescription = $( Read-Host "Enter policy description" )
)
$UriPolicyName = [uri]::EscapeDataString($PolicyName)
$Template = @()
$Template =  @("# $PolicyName`n",
    "$PolicyDescription`n",
    "## Azure Policy Docs`n",
    "See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).`n",
    "`n",
    "## Try with Azure portal`n",
    "[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2F$UriPolicyName%2Fazurepolicy.json)`n",
    "https://github.com/scr8er/shared/blob/master/Azure/Policies/$UriPolicyName/azurepolicy.json`n",
    "`n",
    "## Try with Azure PowerShell`n",
    "````PowerShell`n",
    "# Create the Policy Definition (Subscription scope)`n",
    "$definition = New-AzPolicyDefinition -Name '$PolicyName' -DisplayName '$PolicyName' -description '$PolicyDescription' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/$PolicyName/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/$PolicyName/azurepolicy.parameters.json' -Mode All`n",
    "`n",
    "# Set the scope to a resource group; may also be a subscription or management group`n",
    "$scope = Get-AzResourceGroup -name ResourceGroupName`n",
    "`n",
    "# Create the Policy Assignment`n",
    "$assignment = New-AzPolicyAssignment -Name '$PolicyName' -DisplayName '$PolicyName' -Scope $scope.ResourceId -PolicyDefinition $definition -PolicyParameter $policyparam`n"
    )
If (-not(Test-Path "C:\VSCode\Github Shared\shared\Azure\Policies\$PolicyName"))
    {
    New-Item -ItemType "directory" -Path "C:\VSCode\Github Shared\Shared\Azure\Policies\$PolicyName"
    New-Item -ItemType "file" -Path "C:\VSCode\Github Shared\shared\Azure\Policies\$PolicyName\azurepolicy.json", "C:\VSCode\Github Shared\shared\Azure\Policies\$PolicyName\azurepolicy.parameters.json", "C:\VSCode\Github Shared\shared\Azure\Policies\$PolicyName\azurepolicy.rules.json"
    }
$template | Out-File "C:\VSCode\Github Shared\shared\Azure\Policies\$PolicyName\Readme.md"