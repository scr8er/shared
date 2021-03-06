# RG_EnforceTagsNValue

Enforce a minimum tags and value when trying to create a new resource group.

## Azure Policy Docs

See more information and a complete walk-through of using this sample on
    [docs.microsoft.com](https://docs.microsoft.com/azure/governance/policy/samples).



## Try with Azure portal

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/?#blade/Microsoft_Azure_Policy/CreatePolicyDefinitionBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fscr8er%2Fshared%2Fmaster%2FAzure%2FPolicies%2FRG_EnforceTagsNValue%2Fazurepolicy.json)

https://github.com/scr8er/shared/blob/master/Azure/Policies/RG_EnforceTagsNValue/azurepolicy.json



## Try with Azure PowerShell

``PowerShell

# Create the Policy Definition (Subscription scope)

 = New-AzPolicyDefinition -Name 'RG_EnforceTagsNValue' -DisplayName 'RG_EnforceTagsNValue' -description 'Enforce a minimum tags and value when trying to create a new resource group.' -Policy 'https://github.com/scr8er/shared/blob/master/Azure/Policies/RG_EnforceTagsNValue/azurepolicy.rules.json' -Parameter 'https://github.com/scr8er/shared/blob/master/Azure/Policies/RG_EnforceTagsNValue/azurepolicy.parameters.json' -Mode All



# Set the scope to a resource group; may also be a subscription or management group

 = Get-AzResourceGroup -name ResourceGroupName



# Create the Policy Assignment

 = New-AzPolicyAssignment -Name 'RG_EnforceTagsNValue' -DisplayName 'RG_EnforceTagsNValue' -Scope .ResourceId -PolicyDefinition  -PolicyParameter 

