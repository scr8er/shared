# PsTools
Random scripts gathered last months.

## Automate System Monitoring
Personal project, to develop a way to monitor a client AD users and computers and share useful data in real time.

## Java Deployment
Useful java management scripts.

### Useful random scripts gathered.
#### Uninstall-module
Microsoft script to uninstall deprecated Azure modules (Azure Resource Manager) and download and install the new Azure powershell module.
https://docs.microsoft.com/en-us/powershell/azure/overview?view=azps-2.4.0

```Powershell
.\uninstall-module.ps1
Uninstall-module AzureRm $version

Get-psrepository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az -AllowClobber  # optional -scope CurrentUser
```