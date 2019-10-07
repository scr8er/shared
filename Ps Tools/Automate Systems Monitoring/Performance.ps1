###################################################################################
#
# MONITOR DE RENDIMIENTO
# 
#
###################################################################################

<#$ListSet = Get-Counter -ListSet <NOMBRE MONITOR>
$ListSet.Counter#>

$Monitores = @(
'\Disco lógico(*)\Promedio de bytes de disco/transferencia'
'\Disco lógico(*)\Promedio de bytes de disco/lectura'
'\Disco lógico(*)\Promedio de bytes de disco/escritura'
'\Memoria\Mbytes disponibles'
'\Memoria\Páginas/s'
'\Interfaz de red(*)\Total de bytes/s'
'\Interfaz de red(*)\Longitud de la cola de salida'
'\Procesador lógico del hipervisor Hyper-V(*)\% de tiempo de ejecución total')
Get-Counter -Counter $Monitores -MaxSamples 100 | Export-Counter -Path c:\PPSS\Monitor.csv -FileFormat csv -MaxSize 10