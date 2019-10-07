#Open Windows PowerShell and run the following command:
$fscredential = Get-Credential.
#Enter the name and the password of the service account that you recorded while preparing your SQL Server farm for migration.

#Run the following command where Data Source is the data source value in the policy store connection string value in the following file: %programfiles%\Active Directory Federation Services 2.0\Microsoft.IdentityServer.Servicehost.exe.config.
Add-AdfsFarmNode -ServiceAccountCredential $fscredential -SQLConnectionString "Data Source=$cluster\$instance;Integrated Security=True"