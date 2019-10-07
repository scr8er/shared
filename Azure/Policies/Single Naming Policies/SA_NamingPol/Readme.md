# Approved VM images

This policy enforces a custom name pattern for resources deployed in your environment. You specify
an array of approved image IDs.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
[docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples/allowed-custom-images).

## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fgithubusercontent.com%2FScr8er%2Fazure-resources%2Fblob%2Fmaster%2FAzure-policy%2FAG_NamingPol%2Fazurepolicy.json)
https://github.com/scr8er/Azure-Resources/blob/master/Azure-Policy/AG_NamingPol/azurepolicy.json


## Try with Azure PowerShell

````powershell
# Create the Policy Definition (Subscription scope)
$definition = New-AzPolicyDefinition -Name 'AG_NamingPolicy' -DisplayName 'AG_Naming_Policy' -description 'This policy enforces a custom name pattern' -Policy 'https://github.com/scr8er/Azure-Resources/blob/master/Azure-Policy/AG_NamingPol/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/Azure-Resources/blob/master/Azure-Policy/AG_NamingPol/azurepolicy.parameters.json' -Mode All

# Set the scope to a resource group; may also be a subscription or management group
$scope = Get-AzResourceGroup -Name 'YourResourceGroup'

# Set the Policy Parameter (JSON format)
$policyparam = '{ "namepattern": { "value": "NamePattern" } }'

# Create the Policy Assignment
$assignment = New-AzPolicyAssignment -Name 'allowed-custom-images-assignment' -DisplayName 'Approved VM images Assignment' -Scope $scope.ResourceId -PolicyDefinition $definition -PolicyParameter $policyparam
````
