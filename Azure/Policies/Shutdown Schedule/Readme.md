# Shutdown Schedule

Deploys a shutdown schedule over every not production virtual machines after resource creation if it doesn't exists.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).



## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2FShutdown%20Schedule%2Fazurepolicy.json)

https://github.com/scr8er/shared/blob/master/Azure/Policies/Shutdown%20Schedule/azurepolicy.json



## Try with Azure PowerShell

``PowerShell

# Create the Policy Definition (Subscription scope)

 = New-AzPolicyDefinition -Name 'Shutdown Schedule' -DisplayName 'Shutdown Schedule' -description 'Deploys a shutdown schedule over every not production virtual machines after resource creation if it doesn't exists.' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/Shutdown Schedule/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/Shutdown Schedule/azurepolicy.parameters.json' -Mode All



# Set the scope to a resource group; may also be a subscription or management group

 = Get-AzResourceGroup -name ResourceGroupName



# Create the Policy Assignment

 = New-AzPolicyAssignment -Name 'Shutdown Schedule' -DisplayName 'Shutdown Schedule' -Scope .ResourceId -PolicyDefinition  -PolicyParameter 

