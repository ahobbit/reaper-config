# Dot-sourced by Aplicar-configuracion.ps1. Uses the pinned official release.
function Find-Reaper {
    $candidates = @(
        (Join-Path $env:ProgramFiles 'REAPER (x64)\reaper.exe'),
        (Join-Path $env:ProgramFiles 'REAPER\reaper.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\REAPER (x64)\reaper.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\REAPER\reaper.exe')
    )
    foreach ($key in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\reaper.exe','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\reaper.exe')) {
        if (Test-Path $key) { $candidates += (Get-Item $key).GetValue('') }
    }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }
    return $null
}
function Get-ReaperVersion($path) {
    $info = (Get-Item -LiteralPath $path).VersionInfo
    foreach ($value in @($info.ProductVersion, $info.FileVersion)) {
        if ($value -match '(\d+\.\d+(?:\.\d+){0,2})') { return [version]$Matches[1] }
    }
    throw "No se pudo determinar la version de REAPER en $path"
}
function Ensure-Reaper($bundle) {
    $lock = Get-Content -LiteralPath (Join-Path $bundle 'dependencies.lock.json') -Raw | ConvertFrom-Json
    $required = [version]$lock.versions.reaper
    $installed = Find-Reaper
    if ($installed -and (Get-ReaperVersion $installed) -ge $required) {
        Write-Host "REAPER compatible ya instalado: $installed"; return
    }
    $dep = $lock.files | Where-Object { $_.platform -eq 'windows' -and $_.name -like 'REAPER-*' } | Select-Object -First 1
    if (([uri]$dep.url).Scheme -ne 'https' -or ([uri]$dep.url).Host -ne 'www.reaper.fm') { throw 'URL REAPER no oficial.' }
    $installer = Join-Path $bundle ('Instaladores\' + $dep.name)
    if (-not (Test-Path -LiteralPath $installer)) {
        Write-Host "Descargando REAPER $required desde $($dep.url)"
        New-Item -ItemType Directory -Path (Split-Path $installer) -Force | Out-Null
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $partial = $installer + '.partial'
        Invoke-WebRequest -Uri $dep.url -OutFile $partial -UseBasicParsing
        if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $dep.sha256) { throw 'El instalador descargado no coincide con el hash fijado.' }
        Move-Item -LiteralPath $partial -Destination $installer -Force
    }
    if ((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ne $dep.sha256) { throw 'Hash incorrecto del instalador REAPER.' }
    Write-Host 'Completa el instalador oficial (instalacion NORMAL x64). No abras REAPER al terminar.'
    $process = Start-Process -FilePath $installer -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Instalacion cancelada o fallida: $($process.ExitCode)" }
    $installed = Find-Reaper
    if (-not $installed) { throw 'REAPER no detectado. Usa la ruta normal del instalador y vuelve a ejecutar este script.' }
    if ((Get-ReaperVersion $installed) -lt $required) { throw 'La version instalada sigue siendo anterior a la requerida.' }
    if (Get-Process -Name reaper -ErrorAction SilentlyContinue) { throw 'Cierra REAPER y vuelve a ejecutar el script para aplicar la configuracion.' }
}
