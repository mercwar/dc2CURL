<#
.SYNOPSIS
    dc2URL Root Staging Loader & Eclipse Gate (Fresh Remote Pull Edition)
#>
 
[CmdletBinding()]
param(
    [string]$sound = "off"
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# TLS configuration (TLS 1.2 & TLS 1.3)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Clean presentation setup
$host.UI.RawUI.WindowTitle = "MERCWAR dc2URL & Eclipse Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = [System.Management.Automation.Host.Size]::new(100, 40)
    $host.UI.RawUI.WindowSize = [System.Management.Automation.Host.Size]::new(100, 40)
} catch {}

# --- Registry Persistence for Sound Argument ---
$regPath = "HKCU:\Software\Eclipse\Launcher"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$soundState = "off"
if ($sound -eq "on" -or $sound -eq "true" -or $sound -eq "1") {
    $soundState = "on"
}
Set-ItemProperty -Path $regPath -Name "SoundArg" -Value $soundState -Type String

# Configuration Constants
$RepoUrl      = "https://raw.githubusercontent.com/mercwar/dc2url/main"
$LauncherFile = "launcher.bat"
$EclipseFile  = "setup.bat"
$PurgeFile    = "purge.bat"

function Write-Header {
    param ([string]$StatusText = "Contacting server...")
    Clear-Host
    Write-Host " ___    ___  ___  _   _ ___   _       " -ForegroundColor DarkYellow
    Write-Host "|  _ \ / __||__ \| | | |  _ \| |     " -ForegroundColor DarkYellow
    Write-Host "| |_) | (__  / / | |_| | |_) | |__   " -ForegroundColor Yellow
    Write-Host "|____/ \___||____|\___/|_|\/|____|" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "        [E C L I P S E]   I N S T A L L E R   K E R N E L" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Stargate Subsystem : " -NoNewline -ForegroundColor DarkYellow
    Write-Host "ONLINE" -ForegroundColor White
    Write-Host "Sound Configuration: " -NoNewline -ForegroundColor DarkYellow
    Write-Host "$soundState" -ForegroundColor Cyan
    Write-Host "Status             : " -NoNewline -ForegroundColor DarkYellow
    Write-Host "$StatusText" -ForegroundColor White
    Write-Host ""
}

function Write-Footer {
    Write-Host "====================================================================================" -ForegroundColor DarkYellow
}

function Show-GraphicalProgress {
    param (
        [string]$TaskTitle = "PROCESSING",
        [int]$DurationMs = 2000
    )
    
    $totalBars = 36
    $steptime  = [Math]::Max(10, [int]($DurationMs / $totalBars))
    
    Write-Host "  [#] $TaskTitle" -ForegroundColor Yellow
    try { [Console]::CursorVisible = $false } catch {}
    
    try {
        for ($i = 1; $i -le $totalBars; $i++) {
            Start-Sleep -Milliseconds $steptime
            $percent = [int]($i / $totalBars * 100)
            
            Write-Host -NoNewline "`r  [" -ForegroundColor DarkYellow
            for ($j = 1; $j -le $totalBars; $j++) {
                if ($j -le $i) {
                    if ($j -lt ($totalBars * 0.4)) {
                        Write-Host -NoNewline "#" -ForegroundColor DarkYellow
                    } elseif ($j -lt ($totalBars * 0.8)) {
                        Write-Host -NoNewline "#" -ForegroundColor Yellow
                    } else {
                        Write-Host -NoNewline "#" -ForegroundColor White
                    }
                } else {
                    Write-Host -NoNewline "-" -ForegroundColor DarkGray
                }
            }
            Write-Host -NoNewline "] " -ForegroundColor DarkYellow
            Write-Host ("{0,3}%" -f $percent) -ForegroundColor White -NoNewline
        }
        Write-Host ""
        Write-Host ""
    }
    finally {
        try { [Console]::CursorVisible = $true } catch {}
    }
}

# --- Force Download Helper Function ---
function Get-FreshScript {
    param (
        [string]$FileName,
        [string]$DestinationPath
    )
    
    $remoteUrl = "$RepoUrl/$FileName"
    Write-Host "  [PULL] Fetching fresh copy of $FileName from remote repository..." -ForegroundColor DarkYellow
    
    if (Test-Path $DestinationPath) {
        Remove-Item -Path $DestinationPath -Force -ErrorAction SilentlyContinue
    }
    
    try {
        # Cache-Control no-cache header ensures GitHub raw proxies deliver fresh code
        Invoke-WebRequest -Uri $remoteUrl -OutFile $DestinationPath -UseBasicParsing -Headers @{"Cache-Control"="no-cache, no-store, must-revalidate"}
        Write-Host "  [PULL SUCCESS] Fresh copy of $FileName saved to disk." -ForegroundColor White
        return $true
    } catch {
        Write-Host "  [PULL ERROR] Failed to download fresh copy of $FileName from $remoteUrl : $_" -ForegroundColor Red
        return $false
    }
}

# --- Check Installation Status ---
$isInstalled  = $false
$dc2urlSource = $null
$dc2urlRoot   = $null

try {
    $processInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $processInfo.FileName = "where.exe"
    $processInfo.Arguments = "dc2url"
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    
    $process = [System.Diagnostics.Process]::Start($processInfo)
    $stdout  = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($stdout)) {
        $lines = $stdout -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch '^INFO:' }
        if ($lines.Count -gt 0) {
            $dc2urlSource = $lines[0].Trim()
            $isInstalled  = $true
        }
    }
} catch {
    $isInstalled = $false
}

if ($isInstalled) {
    $parts = $dc2urlSource -split '\\'
    for ($i = 0; $i -lt $parts.Length; $i++) {
        if ($parts[$i] -eq "dc2url") {
            $dc2urlRoot = ($parts[0..$i]) -join '\'
            break
        }
    }
    if (-not $dc2urlRoot) {
        $dc2urlRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $dc2urlSource))
    }

    Write-Header -StatusText "dc2URL command detected at: $dc2urlSource"
    
    Write-Host "  [AVIS ECLIPSE] Select operational mode:" -ForegroundColor Yellow
    Write-Host "    [1] Install/Reinstall Eclipse (Fresh setup)"    -ForegroundColor White
    Write-Host "    [2] Reinstall dc2URL (Fresh launcher)" -ForegroundColor White
    Write-Host "    [3] Purge dc2url/ECLIPSE (Use Windows add/remove First!)"       -ForegroundColor White
    Write-Host "    [4] Exit"                                     -ForegroundColor White
    Write-Host ""
    
    $rawInput = Read-Host "  [AVIS INPUT] Enter selection [1-4]"
    $choice = if ($null -ne $rawInput) { $rawInput.Trim() } else { "" }

    if ([string]::IsNullOrWhiteSpace($choice)) {
        Write-Host ""
        Write-Host "  [AVIS] No selection made. Exiting." -ForegroundColor Gray
        exit 0
    }
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "  [ECLIPSE] Initializing fresh Eclipse installation..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Connecting to Remote Stargate" -DurationMs 1000
            
            $setupPath = Join-Path $dc2urlRoot $EclipseFile
            
            if (-not (Get-FreshScript -FileName $EclipseFile -DestinationPath $setupPath)) {
                Write-Host "  [FATAL] Aborting execution due to missing remote package." -ForegroundColor Red
                exit 1
            }

            try {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$setupPath`"" -Wait -NoNewWindow -ErrorAction Stop
                Write-Host "  [ECLIPSE SUCCESS] Eclipse deployment completed." -ForegroundColor White
            } catch {
                Write-Host "  [ERROR] Execution failed: $_" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        "2" {
            Write-Host ""
            Write-Host "  [AVIS] Initializing fresh dc2URL reinstallation..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Connecting to Remote Stargate" -DurationMs 1000
            
            $launcherLocalPath = Join-Path $dc2urlRoot $LauncherFile

            if (-not (Get-FreshScript -FileName $LauncherFile -DestinationPath $launcherLocalPath)) {
                Write-Host "  [FATAL] Aborting execution due to missing remote package." -ForegroundColor Red
                exit 1
            }

            try {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$launcherLocalPath`"" -Wait -NoNewWindow -ErrorAction Stop
                Write-Host "  [AVIS SUCCESS] Reinstallation completed." -ForegroundColor White
            } catch {
                Write-Host "  [ERROR] Execution failed: $_" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        "3" {
            Write-Host ""
            Write-Host "  [AVIS] Initializing fresh system purge..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Connecting to Remote Stargate" -DurationMs 1000
            
            $purgePath = Join-Path $dc2urlRoot $PurgeFile

            if (-not (Get-FreshScript -FileName $PurgeFile -DestinationPath $purgePath)) {
                Write-Host "  [FATAL] Aborting execution due to missing remote package." -ForegroundColor Red
                exit 1
            }

            try {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c start /wait cmd.exe /k `"$purgePath`"" -Wait -NoNewWindow -ErrorAction Stop
                Write-Host "  [AVIS SUCCESS] Purge execution completed." -ForegroundColor White
            } catch {
                Write-Host "  [ERROR] Execution failed: $_" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "  [AVIS] Operation aborted. Exiting." -ForegroundColor Gray
            exit 0
        }
    }
}

# Initial installation path when dc2url is not detected
Write-Header -StatusText "Contacting server for fresh installer..."

$TempInstaller = Join-Path $env:TEMP "dc2_install_$( [Guid]::NewGuid().ToString().Substring(0, 8) ).bat"
if (-not (Get-FreshScript -FileName $LauncherFile -DestinationPath $TempInstaller)) {
    Write-Host "  [FATAL] Initial download failed." -ForegroundColor Red
    Pause
    exit 1
}

Show-GraphicalProgress -TaskTitle "Initializing Subsystems" -DurationMs 1800

try {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow -ErrorAction Stop
} catch {
    Write-Host "  [ERROR] Execution failed: $_" -ForegroundColor Red
} finally {
    if (Test-Path $TempInstaller) {
        Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
    }
}

Write-Footer
