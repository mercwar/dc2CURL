<#
.SYNOPSIS
    dc2URL Root Staging Loader & Eclipse Gate (Graphical Progress Bar Edition)
#>

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# Modern TLS configuration (covers TLS 1.2 & TLS 1.3)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Clean presentation setup
$host.UI.RawUI.WindowTitle = "MERCWAR dc2URL & Eclipse Launcher v1.0"
try {
    $host.UI.RawUI.BufferSize = [System.Management.Automation.Host.Size]::new(100, 40)
    $host.UI.RawUI.WindowSize = [System.Management.Automation.Host.Size]::new(100, 40)
} catch {
    # Non-critical if running in hosts without window geometry access
}

# Configuration Constants
$RepoUrl        = "https://raw.githubusercontent.com/mercwar/dc2url/main"
$LauncherFile   = "launcher.bat"
$EclipseFile    = "setup.bat"
$PurgeFile      = "purge.bat"
$TempInstaller  = Join-Path $env:TEMP "dc_install_$( [Guid]::NewGuid().ToString().Substring(0, 8) ).bat"

function Write-Header {
    param ([string]$StatusText = "Contacting server...")
    Clear-Host
    Write-Host " ___   ___  ___  _   _ ___  _       " -ForegroundColor DarkYellow
    Write-Host "| \ \ / __||_  || | | | _ \| |     " -ForegroundColor DarkYellow
    Write-Host "| |) | (__  _|_ | |_| |   /| |__   " -ForegroundColor Yellow
    Write-Host "|___/ \___||___| \___/|_|_\ |____|" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "        [E C L I P S E]    I N S T A L L E R    K E R N E L" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Stargate Subsystem : " -NoNewline -ForegroundColor DarkYellow
    Write-Host "ONLINE" -ForegroundColor White
    Write-Host "Status             : " -NoNewline -ForegroundColor DarkYellow
    Write-Host "$StatusText" -ForegroundColor White
    Write-Host ""
}

function Write-Footer {
    Write-Host "====================================================================================" -ForegroundColor DarkYellow
}

# --- Graphical ASCII Progress Bar Engine with Cursor Suppression ---
function Show-GraphicalProgress {
    param (
        [string]$TaskTitle = "PROCESSING",
        [int]$DurationMs = 2000
    )
    
    $totalBars = 36
    $steptime  = [Math]::Max(10, [int]($DurationMs / $totalBars))
    
    Write-Host "  #$TaskTitle" -ForegroundColor Yellow
    
    # Hide the terminal cursor to prevent blinking/flashing artifacts
    try { [Console]::CursorVisible = $false } catch {}
    
    try {
        for ($i = 1; $i -le $totalBars; $i++) {
            Start-Sleep -Milliseconds $steptime
            
            $percent = [int]($i / $totalBars * 100)
            
            Write-Host -NoNewline "`r  [" -ForegroundColor DarkYellow
            
            for ($j = 1; $j -le $totalBars; $j++) {
                if ($j -le $i) {
                    if ($j -lt $totalBars * 0.4) {
                        Write-Host -NoNewline "#" -ForegroundColor DarkYellow
                    } elseif ($j -lt $totalBars * 0.8) {
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
        # Always restore the cursor visibility even if interrupted
        try { [Console]::CursorVisible = $true } catch {}
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

# --- Flow A: System Already Installed ---
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
    Write-Host "    [1] Install Eclipse"                     -ForegroundColor White
    Write-Host "    [2] Reinstall dc2URL"                    -ForegroundColor White
    Write-Host "    [3] Purge dc2URL"                        -ForegroundColor White
    Write-Host "    [4] Exit"                                -ForegroundColor White
    Write-Host ""
    
    $choice = (Read-Host "  [AVIS INPUT] Enter selection [1-4]").Trim()
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "  [ECLIPSE] Initializing Eclipse installation protocol..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Deploying Eclipse Gate" -DurationMs 1200
            
            $setupPath = Join-Path $dc2urlRoot $EclipseFile
            if (Test-Path $setupPath) {
                try {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$setupPath`"" -Wait -NoNewWindow -ErrorAction Stop
                    Write-Host "  [ECLIPSE SUCCESS] Eclipse deployment sequence completed." -ForegroundColor White
                } catch {
                    Write-Host "  [ERROR] Eclipse installation was cancelled or failed: $_" -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "  [ERROR] $EclipseFile not found at: $setupPath" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        "2" {
            Write-Host ""
            Write-Host "  [AVIS] Proceeding with dc2URL reinstallation..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Preparing Core Rebuild" -DurationMs 1000
            
            $launcherLocalPath = Join-Path $dc2urlRoot $LauncherFile
            if (Test-Path $launcherLocalPath) {
                try {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$launcherLocalPath`"" -Wait -NoNewWindow -ErrorAction Stop
                    Write-Host "  [AVIS SUCCESS] Reinstallation completed." -ForegroundColor White
                } catch {
                    Write-Host "  [ERROR] Reinstallation was cancelled or failed: $_" -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "  [ERROR] $LauncherFile not found at: $launcherLocalPath" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        "3" {
            Write-Host ""
            Write-Host "  [AVIS] Initializing dc2URL system purge protocol..." -ForegroundColor DarkYellow
            Show-GraphicalProgress -TaskTitle "Executing Purge Sequence" -DurationMs 1000
            
            $purgePath = Join-Path $dc2urlRoot $PurgeFile
            if (Test-Path $purgePath) {
                try {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$purgePath`"" -Wait -NoNewWindow -ErrorAction Stop
                    Write-Host "  [AVIS SUCCESS] Purge execution completed." -ForegroundColor White
                } catch {
                    Write-Host "  [ERROR] Purge operation was cancelled or failed: $_" -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "  [ERROR] $PurgeFile not found at: $purgePath" -ForegroundColor Red
                exit 1
            }
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "  [AVIS] Operation aborted by user. Exiting." -ForegroundColor Gray
            exit 0
        }
    }
}

Write-Header -StatusText "Contacting server..."

$TargetUrl = "$RepoUrl/$LauncherFile"
Write-Host "    [AVIS] Searching for installation gateway" -ForegroundColor DarkYellow
Write-Host "    [AVIS] Target Source : " -NoNewline         -ForegroundColor Gray
Write-Host "$TargetUrl"                                     -ForegroundColor White
Write-Host "    [AVIS] Target Output : " -NoNewline         -ForegroundColor Gray
Write-Host "$TempInstaller"                                 -ForegroundColor White
Write-Host ""

# Play custom progress bar while downloading silently in the background
$downloadJob = Start-Job -ScriptBlock {
    param($url, $output)
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
} -ArgumentList $TargetUrl, $TempInstaller

Show-GraphicalProgress -TaskTitle "Connecting to Gateway & Downloading Payload" -DurationMs 2000

# Ensure download is fully completed before moving on
Wait-Job $downloadJob | Out-Null
Receive-Job $downloadJob | Out-Null
Remove-Job $downloadJob

if (-not (Test-Path $TempInstaller)) {
    Write-Host ""
    Write-Host "  [AVIS ERROR] Download failed or file missing." -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "  [AVIS SUCCESS] Payload secured on disk." -ForegroundColor White
Write-Host ""

Write-Host "  [AVIS ECLIPSE] Searching for Cyborg Launcher..." -ForegroundColor Gray
Show-GraphicalProgress -TaskTitle "Initializing Cyborg Subsystems" -DurationMs 1800

Write-Host ""
Write-Host "  [AVIS] Calling Portal Installer"          -ForegroundColor DarkYellow
Write-Host "  [ECLIPSE] AVIS REPORTED SUCCESS..."     -ForegroundColor Gray
Write-Footer
Write-Host ""

Start-Sleep -Milliseconds 600

try {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow -ErrorAction Stop
} catch {
    Write-Host "  [ERROR] Installer execution was cancelled or failed: $_" -ForegroundColor Red
}

# Local workspace dynamic garbage clean-up
if (Test-Path $TempInstaller) {
    Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  [ECLIPSE] dc2url will be visible in your add/remove programs after the registration." -ForegroundColor White
Write-Host "  [ECLIPSE] Auto updates are not supported at this time, you may run this irm or launcher at any time to update dc2url." -ForegroundColor White
Write-Footer
