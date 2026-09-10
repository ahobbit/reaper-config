$ErrorActionPreference = 'Stop'
try {
    if (-not [Environment]::Is64BitOperatingSystem) { throw 'This package requires 64-bit Windows.' }
    if (Get-Process -Name reaper -ErrorAction SilentlyContinue) { throw 'Please close REAPER before continuing.' }
    $bundle = $PSScriptRoot
    $resource = Join-Path $env:APPDATA 'REAPER'
    $documents = [Environment]::GetFolderPath('MyDocuments')
    if (-not $documents) { throw 'Could not locate Documents folder.' }
    # Validate all included payloads before changing destination files.
    $manifest = Get-Content -LiteralPath (Join-Path $bundle 'SHA256.json') -Raw | ConvertFrom-Json
    foreach ($entry in $manifest) {
        $file = Join-Path $bundle $entry.path
        if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $entry.sha256) {
            throw "Incomplete or modified file: $($entry.path)"
        }
    }
    . (Join-Path $bundle 'Prepare-REAPER.ps1')
    Ensure-Reaper $bundle
    $backup = Join-Path $documents ('REAPER\Configuration Backups\Before-Reapertips-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
    if (Test-Path -LiteralPath $resource) {
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $resource -Destination (Join-Path $backup 'REAPER') -Recurse
    }
    New-Item -ItemType Directory -Path $resource -Force | Out-Null
    foreach ($name in @('Projects','Peaks','Auto Backups','Unsaved Projects')) {
        New-Item -ItemType Directory -Path (Join-Path $documents "REAPER\$name") -Force | Out-Null
    }
    $source = Join-Path $bundle 'Configuration'
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    foreach ($file in Get-ChildItem -LiteralPath $source -Recurse -File) {
        $relative = $file.FullName.Substring($source.Length + 1)
        $target = Join-Path $resource $relative
        New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
        if ($file.Extension -eq '.ini') {
            $content = [IO.File]::ReadAllText($file.FullName)
            $content = $content.Replace('@@RESOURCE@@', $resource.Replace('\','/')).Replace('@@DOCUMENTS@@', $documents.Replace('\','/'))
            if ($content.Contains('@@RESOURCE@@') -or $content.Contains('@@DOCUMENTS@@')) { throw 'Unadapted placeholders remain in ini files.' }
            [IO.File]::WriteAllText($target, $content, $utf8)
        } else {
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
        }
    }
    $plugins = Join-Path $resource 'UserPlugins'
    New-Item -ItemType Directory -Path $plugins -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $bundle 'Installers\reaper_reapack-x64.dll') -Destination $plugins -Force
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class ReapertipsNative {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool WritePrivateProfileStructW(string section, string key, byte[] data, uint length, string path);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool GetPrivateProfileStructW(string section, string key, byte[] data, uint length, string path);
    [DllImport("gdi32.dll", CharSet=CharSet.Unicode)]
    public static extern int AddFontResourceW(string path);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    public static extern IntPtr SendMessageTimeoutW(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
}
'@
    $colors = Get-Content -LiteralPath (Join-Path $bundle 'windows-colors.json') -Raw | ConvertFrom-Json
    [byte[]]$bytes = New-Object byte[] 64
    for ($i=0; $i -lt 16; $i++) { [BitConverter]::GetBytes([uint32]$colors[$i]).CopyTo($bytes, $i*4) }
    $ini = Join-Path $resource 'reaper.ini'
    if (-not [ReapertipsNative]::WritePrivateProfileStructW('reaper','custcolors',$bytes,64,$ini)) { throw 'Failed to save colors to reaper.ini.' }
    [byte[]]$check = New-Object byte[] 64
    if (-not [ReapertipsNative]::GetPrivateProfileStructW('reaper','custcolors',$check,64,$ini)) { throw 'Failed to verify saved colors.' }
    if ([Convert]::ToBase64String($bytes) -ne [Convert]::ToBase64String($check)) { throw 'Saved color verification mismatch.' }
    $fonts = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    New-Item -ItemType Directory -Path $fonts -Force | Out-Null
    $fontKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    New-Item -Path $fontKey -Force | Out-Null
    $fontNames = @{'FiraSans-Bold.ttf'='Fira Sans Bold (TrueType)';'FiraSans-Regular.ttf'='Fira Sans Regular (TrueType)';'Roboto-Bold.ttf'='Roboto Bold (TrueType)'}
    foreach ($name in $fontNames.Keys) {
        $target = Join-Path $fonts $name
        if (Test-Path -LiteralPath $target) {
            New-Item -ItemType Directory -Path (Join-Path $backup 'Fonts') -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination (Join-Path $backup 'Fonts') -Force
        }
        Copy-Item -LiteralPath (Join-Path $bundle "Fonts\$name") -Destination $target -Force
        New-ItemProperty -Path $fontKey -Name $fontNames[$name] -Value $target -PropertyType String -Force | Out-Null
        [ReapertipsNative]::AddFontResourceW($target) | Out-Null
    }
    $result = [IntPtr]::Zero
    [ReapertipsNative]::SendMessageTimeoutW([IntPtr]0xffff,0x001D,[IntPtr]::Zero,[IntPtr]::Zero,2,1000,[ref]$result) | Out-Null
    Write-Host "Configuration and colors installed to: $resource" -ForegroundColor Green
    Write-Host "Backup (if previous configuration existed): $backup"
    Write-Host 'Install SWS now using the included installer if not already installed.'
    Write-Host 'Open REAPER and select your audio interface in Preferences > Audio > Device.'
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'The previous configuration, if any existed, is in Documents\REAPER\Configuration Backups.'
    exit 1
}
