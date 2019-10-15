# Variables
$Listener =

# Adfs Configuration Database connection string change.
$temp = Get-WmiObject -namespace root/ADFS -class SecurityTokenService
$temp.ConfigurationdatabaseConnectionstring = ”data source=$listener; initial catalog=adfsconfiguration;integrated security=true”
$temp.put()

# Adfs artifact resolution Database connection string change.
Set-AdfsProperties –artifactdbconnection ”Data source=$listener;Initial Catalog=AdfsArtifactStore;Integrated Security=True”