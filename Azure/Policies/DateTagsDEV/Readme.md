# DateTagsDEV

Enforces creation and expiration date tags over non production resource groups.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).



## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2FDateTagsDEV%2Fazurepolicy.json)

https://github.com/scr8er/shared/blob/master/Azure/Policies/DateTagsDEV/azurepolicy.json



## Try with Azure PowerShell

``PowerShell

# Create the Policy Definition (Subscription scope)

 = New-AzPolicyDefinition -Name 'DateTagsDEV' -DisplayName 'DateTagsDEV' -description 'Enforces creation and expiration date tags over non production resource groups.' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/DateTagsDEV/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/DateTagsDEV/azurepolicy.parameters.json' -Mode All



# Set the scope to a resource group; may also be a subscription or management group

 = Get-AzResourceGroup -name ResourceGroupName



# Create the Policy Assignment

 = New-AzPolicyAssignment -Name 'DateTagsDEV' -DisplayName 'DateTagsDEV' -Scope .ResourceId -PolicyDefinition  -PolicyParameter 

