## Azlogin
```powershell
Connect-AzAccount -Credential (Get-Credential)
```
# Deployment
Powershell and resource manager deployments and tools.

## Set-NewSubscription
Deploy a resource group with the following resources: Vnet, subnet, network security groups, public ip address, virtual network gateway, network watcher, express route connections, monitoring Linux virtual machine. This script is prepared to be used when a new subscription is generated.

## Deploy-VnetTemplate
Simple function to build vnet parameter json files. It should be useful to learn how to work with .json files, create, modify and save.

## Parameters and templates
Place to save our parameter and resource templates. Useful to deploy highly configurated resources.

# Policies
Policies deployed in Azure.

# RBAC
Custom roles created.

## Get-AzRRules
Fast way to find ARM resource provider operations from an excel file while working on RBAC. Requires psexcel module.
https://docs.microsoft.com/es-es/azure/role-based-access-control/resource-provider-operations

## Get-AzureADUserInfo
Provides information about AAD user licenses.
https://github.com/Azure/azure-docs-powershell-azuread/blob/master/docs-conceptual/azureadps-2.0/working-with-licenses.md

## Deployment-Menu
Compilation of simple functions in a single script to ease dialy azure console administration.

## New-AzAGWcustomrule
Application gateway (firewall) custom rule example.
