# Dot-sourced by Apply-configuration.ps1. Uses the pinned official release.
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
    throw "Could not determine REAPER version in $path"
}
function Ensure-Reaper($bundle) {
    $lock = Get-Content -LiteralPath (Join-Path $bundle 'dependencies.lock.json') -Raw | ConvertFrom-Json
    $required = [version]$lock.versions.reaper
    $installed = Find-Reaper
    if ($installed -and (Get-ReaperVersion $installed) -ge $required) {
        Write-Host "Compatible REAPER already installed: $installed"; return
    }
    $dep = $lock.files | Where-Object { $_.platform -eq 'windows' -and $_.name -like 'REAPER-*' } | Select-Object -First 1
    if (([uri]$dep.url).Scheme -ne 'https' -or ([uri]$dep.url).Host -ne 'www.reaper.fm') { throw 'Unofficial REAPER URL.' }
    $installer = Join-Path $bundle ('Installers\' + $dep.name)
    if (-not (Test-Path -LiteralPath $installer)) {
        Write-Host "Downloading REAPER $required from $($dep.url)"
        New-Item -ItemType Directory -Path (Split-Path $installer) -Force | Out-Null
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $partial = $installer + '.partial'
        Invoke-WebRequest -Uri $dep.url -OutFile $partial -UseBasicParsing
        if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $dep.sha256) { throw 'Downloaded installer does not match pinned hash.' }
        Move-Item -LiteralPath $partial -Destination $installer -Force
    }
    if ((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ne $dep.sha256) { throw 'REAPER installer hash mismatch.' }
    Write-Host 'Complete the official installer (Standard x64 installation). Do NOT launch REAPER when finished.'
    $process = Start-Process -FilePath $installer -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Installation cancelled or failed: $($process.ExitCode)" }
    $installed = Find-Reaper
    if (-not $installed) { throw 'REAPER not detected. Use standard installer path and run this script again.' }
    if ((Get-ReaperVersion $installed) -lt $required) { throw 'Installed version is still older than required version.' }
    if (Get-Process -Name reaper -ErrorAction SilentlyContinue) { throw 'Close REAPER and run the script again to apply configuration.' }
}
