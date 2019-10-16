# Variables
$Listener = "Listener.subdomain.domain.local"

# Detener el servicio en todos los servidores de la granja.
NET STOP adfssrv

# Adfs Configuration Database connection string change.
$temp = Get-WmiObject -namespace root/ADFS -class SecurityTokenService
$temp.ConfigurationdatabaseConnectionstring = ”data source=$Listener; initial catalog=adfsconfigurationV3; integrated security=true; connect timeout=25; MultiSubnetFailover=true”
$temp.put()

# Iniciar el servicio antes de modificar la cadena de conexión contra AdfsArtifact y ejecutar únicamente en un servidor.
NET START adfssrv

# Adfs artifact resolution Database connection string change.
Set-AdfsProperties –artifactdbconnection ”data source=$Listener; initial catalog=adfsconfigurationV3; integrated security=true; connect timeout=25; MultiSubnetFailover=true”