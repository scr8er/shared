Add-PSSnapin Microsoft.Adfs.PowerShell
Get-ADFSRelyingPartyTrust | out-file .\RPT.txt
Get-ADFSAttributeStore | out-file .\AttributeSto.txt
Get-ADFSCertificate | out-file .\cert.txt
Get-ADFSClaimDescription | out-file .\claimdesc.txt
Get-ADFSClaimsProviderTrust | out-file .\claimprov.txt
Get-ADFSEndpoint | out-file .\endp.txt
Get-ADFSProperties | out-file .\prop.txt
Get-ADFSProxyProperties | out-file .\proxprop.txt
Get-ADFSSyncProperties | out-file .\syncprop.txt