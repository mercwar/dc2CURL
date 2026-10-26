<#
.SYNOPSIS
    dc2URL Root Staging Loader
.DESCRIPTION
    Safely downloads and executes the remote staging bootstrap script with TLS 1.2 enforcement,
    structured logging, proper exit-code handling, and automatic temporary file cleanup.
#>

[CmdletBinding()]
param()

# Strict error handling and security baseline
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Configuration
$RepoUrl      = 'https://raw.githubusercontent.com/mercwar/dc2url/main/install.bat'
$TempDir      = [System.IO.Path]::GetTempPath()
$UniqueId     = [Guid]::NewGuid().ToString('N').Substring(0, 8)
$TempInstaller = Join-Path -Path $TempDir -ChildPath "dc2_install_$UniqueId.bat"

function Write-StyledMessage {
    param (
        [Parameter(Mandatory)]
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Message,
        [ConsoleColor]$Color = 'Cyan'
    )
    Write-Host "[$Level] $Message" -ForegroundColor $Color
}

try {
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-StyledMessage -Level "INFO" -Message "dc2URL :: BOOTSTRAP LOADER" -Color Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan

    Write-StyledMessage -Level "INFO" -Message "Downloading staging wrapper engine from GitHub..." -Color Yellow

    # Use WebRequest with basic parsing for maximum compatibility
    Invoke-WebRequest -Uri $RepoUrl -OutFile $TempInstaller -UseBasicParsing

    Write-StyledMessage -Level "INFO" -Message "Launching interactive staging wrapper..." -Color Green

    # Execute cmd.exe safely waiting for completion
    $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempInstaller`"" -Wait -NoNewWindow -PassThru

    if ($Process.ExitCode -ne 0) {
        throw "Installer exited with non-zero error code: $($Process.ExitCode)"
    }
}
catch {
    Write-StyledMessage -Level "ERROR" -Message $_.Exception.Message -Color Red
    exit 1
}
finally {
    if (Test-Path -LiteralPath $TempInstaller) {
        Remove-Item -LiteralPath $TempInstaller -Force -ErrorAction SilentlyContinue
    }
}
