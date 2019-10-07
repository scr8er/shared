####################################################################################
# Fuentes de Datos y Destinos
####################################################################################
#Control de idioma
$Idioma = GET-WinSystemLocale

# Listado de usuarios administradores a nivel de dominio que consultará el script. Debe ser accesible desde cualquier servidor.
$DLAdmins = "C:\Repositorio\Recursos\DomainAdmin.txt"

# Destino de la información extraída de tareas y servicios. Debe ser accesible desde cualquier servidor.
$DestinoTareas = "C:\Repositorio\Recursos\Tareas1.csv"
$DestinoServicios = "C:\Repositorio\Recursos\Servicios1.csv"

####################################################################################
# Task Scheduled
####################################################################################
if ($idioma.DisplayName -like "Español*")
    {
    $schtasklist = schtasks /query /fo csv /v | ConvertFrom-Csv | where {($_."nombre de tarea" -notlike "\*\*") -and ($_."nombre de tarea" -ne "nombre de tarea")}  | select "Nombre de host","Nombre de tarea","Ultimo tiempo de ejecucion","Ejecutar como usuario","Estado de tarea programada"
    }
else{
    $schtasklist = schtasks /query /fo csv /v | ConvertFrom-Csv | where {($_."TaskName" -notlike "\*\*") -and ($_."TaskName" -ne "TaskName")}  | select "HostName","TaskName","Last Run Time","Run As User","Status"
    }
####################################################################################


####################################################################################
# Services
####################################################################################
$ListOfServices = Get-WmiObject Win32_Service
	$Services = @()
    $Tasks = @()
    $Servicios = @()
	Foreach ($Service in $ListOfServices)
    {
		$Details = "" | Select HostName,Name,Account,"Start Mode",State
		$Details.HostName = hostname
		$Details.Name = $Service.Caption
		$Details.Account = $Service.Startname
		$Details."Start Mode" = $Service.StartMode
        $Details.State = $Service.State
        $Services += $Details
	}

    $AdministratorsGroupSID1 = 'S-1-5-32-544'
    $DLAAdmins = Get-ADGroupMember -Identity $AdministratorsGroupSID1 -Recursive
################################ End of Service ####################################

####################################################################################
# Comparativa de los datos vs administradores a nivel de dominio.
####################################################################################
$Adminlist = GC $DLAdmins
Foreach ($Adminuser in $Adminlist)
    {
    foreach ($Task in $schtasklist)
        {
        if ($Task."ejecutar como usuario" -like "*$Adminuser")
            {
            $Tasks += $Task
            }
        }
    foreach ($SvcAccount in $Services)
        {
        if ($SvcAccount.account -like "$Adminuser*")
            {
            $Servicios += $SvcAccount
            }
        }
    }
$csvtask = Import-csv $DestinoTareas -header "HostName", "TaskName", "LastExecution", "Run As User", "Status"
$csvServices = Import-csv $DestinoServicios -header "HostName", "ServiceName", "Account", "StartMode", "Status"
foreach ($t in $Tasks)
    {
        $newtaskrow = New-Object PsObject -Property @{ HostName = $t."Nombre de host"; TaskName = $t."Nombre de tareaTaskname"; LastExecution = $t."Ultimo tiempo de ejecucion"; "Run As User" = $t."Ejecutar como usuario"; Status = $t."Estado de tarea programada"}
        $csvtask
    }


$Tasks | Export-Csv -Path $DestinoTareas
$Servicios | Export-Csv -Path $DestinoServicios

$fileContent = Import-csv $file -header "Date", "Description"
$newRow = New-Object PsObject -Property @{ Date = 'Text4' ; Description = 'Text5' }
$fileContent += $newRow