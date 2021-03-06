# ExpiredResourceGroups

Audit resource groups where expiration date tag has passed. Only applies to not production enviroment.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).



## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2FExpiredResourceGroups%2Fazurepolicy.json)

https://github.com/scr8er/shared/blob/master/Azure/Policies/ExpiredResourceGroups/azurepolicy.json



## Try with Azure PowerShell

``PowerShell

# Create the Policy Definition (Subscription scope)

 = New-AzPolicyDefinition -Name 'ExpiredResourceGroups' -DisplayName 'ExpiredResourceGroups' -description 'Audit resource groups where expiration date tag has passed. Only applies to not production enviroment.' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/ExpiredResourceGroups/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/ExpiredResourceGroups/azurepolicy.parameters.json' -Mode All



# Set the scope to a resource group; may also be a subscription or management group

 = Get-AzResourceGroup -name ResourceGroupName



# Create the Policy Assignment

 = New-AzPolicyAssignment -Name 'ExpiredResourceGroups' -DisplayName 'ExpiredResourceGroups' -Scope .ResourceId -PolicyDefinition  -PolicyParameter 

