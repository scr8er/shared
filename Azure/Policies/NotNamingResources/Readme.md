# NotNamingResources

Audit resources out of naming policy filters.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).



## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2FNotNamingResources%2Fazurepolicy.json)

https://github.com/scr8er/shared/blob/master/Azure/Policies/NotNamingResources/azurepolicy.json



## Try with Azure PowerShell

``PowerShell

# Create the Policy Definition (Subscription scope)

 = New-AzPolicyDefinition -Name 'NotNamingResources' -DisplayName 'NotNamingResources' -description 'Audit resources out of naming policy filters.' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/NotNamingResources/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/NotNamingResources/azurepolicy.parameters.json' -Mode All



# Set the scope to a resource group; may also be a subscription or management group

 = Get-AzResourceGroup -name ResourceGroupName



# Create the Policy Assignment

 = New-AzPolicyAssignment -Name 'NotNamingResources' -DisplayName 'NotNamingResources' -Scope .ResourceId -PolicyDefinition  -PolicyParameter 

