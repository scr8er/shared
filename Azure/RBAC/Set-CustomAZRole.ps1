# CUSTOM ROLE DEFINITIONS #1: permisos para instalar máquinas en redes de un grupo de recursos al que no tiene acceso.
# En caso de modificar un rol existente, "cargamos" la plantilla que modificaremos añadiendo y quitando roles. Si se trata de un rol nuevo cargamos el contenido de cualquier otro rol predefinido.
$customrole1 = Get-AzRoleDefinition "Custom Role #1 - Network"


#CLEAR FIELDS Eliminamos los campos antes de agregar entradas.
$customrole1.Actions.Clear()
$customrole1.NotActions.Clear()
$customrole1.AssignableScopes.Clear()

#ACTION ADD: Permisos concedidos
$customrole1.Actions.Add("Microsoft.Network/virtualNetworks/read")
$customrole1.Actions.Add("Microsoft.Network/virtualNetworks/join/action")
$customrole1.Actions.Add("Microsoft.Network/networkInterfaces/read")
$customrole1.Actions.Add("Microsoft.Network/networkInterfaces/join/action")
$customrole1.Actions.Add("Microsoft.Network/networkInterfaces/ipconfigurations/read")
$customrole1.Actions.Add("Microsoft.Network/networkInterfaces/ipconfigurations/join/action")
$customrole1.Actions.Add("Microsoft.Network/virtualNetworks/subnets/read")
$customrole1.Actions.Add("Microsoft.Network/virtualNetworks/subnets/join/action")

#NOT ACTIONS ADD: Permisos denegados
$customrole1.NotActions.Add("Microsoft.Network/virtualNetworks/subnets/write")

#ASSIGNABLESCOPE ADD: Ámbito (suscripción o grupo de recursos)
$customrole1.assignableScopes = "/subscriptions/643f7196-adee-4649-8171-71879fdb855a/ResourceGroups/RG_NETWORK_ITOPS_EXP"


#En caso de que ya esté creado y solamente queramos modificar, no es necesario crear un rol nuevo, bastaría con:
Set-AzRoleDefinition -role $customrole1

#Por último se asigna el rol sobre el control de acceso de la suscripción o grupo de recursos.
#########################################################################################################################

# CUSTOM ROLE DEFINITIONS #2
$customrole2 = Get-AzRoleDefinition "Custom Role #1"

#CLEAR FIELDS
$customrole2.Actions.Clear()
$customrole2.NotActions.Clear()
$customrole2.AssignableScopes.Clear()

#ACTION ADD
$customrole2.Actions.Add("Microsoft.Resources/deployments/validate/action")
$customrole2.Actions.Add("Microsoft.Storage/storageAccounts/read")
$customrole2.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$customrole2.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/resources/read")
$customrole2.Actions.Add("Microsoft.Network/networkInterfaces/read")
$customrole2.Actions.Add("Microsoft.Network/networkInterfaces/join/action")
$customrole2.Actions.Add("Microsoft.Network/networkInterfaces/ipconfigurations/read")
$customrole2.Actions.Add("Microsoft.Network/networkInterfaces/ipconfigurations/join/action")
$customrole2.Actions.Add("Microsoft.Network/networkInterfaces/write")
$customrole2.Actions.Add("Microsoft.Compute/virtualMachines/write")
$customrole2.Actions.Add("Microsoft.Compute/virtualMachines/read")
$customrole2.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$customrole2.Actions.Add("Microsoft.Compute/virtualMachines/deallocate/action")
$customrole2.Actions.Add("Microsoft.Resources/deployments/write")
$customrole2.Actions.Add("Microsoft.Storage/storageAccounts/write")
$customrole2.Actions.Add("Microsoft.DevTestLab/schedules/write")
$customrole2.Actions.Add("Microsoft.Network/networkSecurityGroups/write")

#ASSIGNABLESCOPE ADD
$customrole2.assignableScopes = "/subscriptions/643f7196-adee-4649-8171-71879fdb855a/ResourceGroups/RG_ADFS_LAB_EXP"

Set-AzRoleDefinition -role $customrole2
(get-AzRoleDefinition "Custom Role #1").actions
(get-AzRoleDefinition "Custom Role #1 - network").actions

#NOT ACTIONS ADD 
<#$customrole1.NotActions.Add("Microsoft.Network/virtualNetworks/*/write")
$customrole1.NotActions.Add("Microsoft.Network/virtualNetworks/*/delete")
$customrole1.NotActions.Add("Microsoft.Resources/subscriptions/*/write")
$customrole1.NotActions.Add("Microsoft.Resources/subscriptions/*/delete")
$customrole1.NotActions.Add("Microsoft.Resources/subscriptions/resourceGroups/*/write")
$customrole1.NotActions.Add("Microsoft.Resources/subscriptions/resourceGroups/*/delete")
$customrole1.NotActions.Add("Microsoft.Storage/*/write")
$customrole1.NotActions.Add("Microsoft.Storage/*/delete")
$customrole1.NotActions.Add("Microsoft.ClassicCompute/*/write")
$customrole1.NotActions.Add("Microsoft.ClassicCompute/*/delete")
$customrole1.NotActions.Add("Microsoft.Network/virtualNetworks/subnets/write")
#>