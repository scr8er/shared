# Scr8er CopyRight 2019
# Randomizer loop found @ Reddit, posted by Vermix.

# Parameters
param (
    [string]$NewAdminUser = $( Read-Host "New local administrator Name" ),
    [string]$LapsPath = $( Read-Host "Laps installer path" )
)

# Instalando LAPS, generando un usuario admin nuevo.
if ( Test-Path "C:\Program Files\LAPS\CSE\Admpwd.dll" -ErrorAction SilentlyContinue ) {
    Write-Host "Laps installed, no further actions required" -ForegroundColor Green
}
else {
    Write-Host "Previous laps installation not found. Testing $LapsPath" -ForegroundColor Green
    if (-not (Test-Path $LapsPath)) {
        Write-Host "Installer not found." -ForegroundColor Red
        Break
    }
    else {
        Write-Host "Found. Performing laps install." -ForegroundColor Green
        msiexec /q /i $LapsPath CUSTOMADMINNAME=$AdminUser 
    }

    # Timing
    Write-Host "Installation checks." -ForegroundColor Green
    [int]$sleep = 0
    do {
        Start-Sleep -seconds 5
        $sleep++
        if ($sleep -gt 5) { Break }
    }
    while (-not (Get-LocalUser LAPDMIN -ErrorAction SilentlyContinue))

    # Deshabilitando usuario administrador y modificando el nombre por uno aleatorio.
    if ((Get-LocalUser $AdminUser).Enabled) {
        Get-LocalUser $adminUser | Set-LocalUser -Description "Admin account created by LAPS."
        Write-Host "New Admin User $AdminUser created. Modifying default integrated admin account." -ForegroundColor Green
        $max = Get-Random -Minimum 5 -Maximum 12
        $start = Get-Random -maximum 100
        $start = $start % 2
        $nombre = ""
        for ($counter = $start; $counter -le $max; $counter++) {
            if ($counter % 2) {
                $letra = Get-Random "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "x", "z", "ch", "ck", "sh"
            }
            else {
                $letra = Get-Random "a", "e", "i", "o", "u", "y", "oo", "ai"
            }
            $nombre += $letra
        }
        $nombre
        $admin = (gwmi -query "Select * From Win32_UserAccount Where LocalAccount = TRUE AND SID LIKE 'S-1-5%-500'")
        $admin.rename("$nombre")
        Write-Host "Administrator modified and disabled." -ForegroundColor Green
        Get-LocalUser $nombre | Disable-LocalUser
    }
}