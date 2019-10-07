function DescargarArchivo([string]$URLOrigen, [string]$destino)
{
  Remove-Item -Path $destino -Force -ErrorAction Ignore
  Invoke-WebRequest $RULOrigen -OutFile $destino 
}
DescargarArchivo -sourceUrl -destinationFile -force 