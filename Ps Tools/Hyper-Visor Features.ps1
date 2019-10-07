# Deshabilita las características instaladas.
foreach ( $i in $c_hab ) {
    if ($i -match "Hyper-V")
    {
    Write-host "`n $i se mantendrá instalada"
    }
    else
    {
    Write-Host "`nDeshabilitando característica: $i"
    dism /online /Disable-Feature /FeatureName:$i /norestart /quiet
    }
}