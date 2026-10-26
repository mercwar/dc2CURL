# install.ps1 (Hosted on ://githubusercontent.com)
$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "             dc2URL IRM Loader               " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. PROGRAMMATIC CHECK FOR PRE-EXISTING WINDOWS OS INSTALLATION DETAILS
$RegUserPath = "HKCU:\Environment"
$ExistingPath = $null

if (Get-ItemProperty -Path $RegUserPath -Name "dc2url_path" -ErrorAction SilentlyContinue) {
    $ExistingPath = (Get-ItemProperty -Path $RegUserPath -Name "dc2url_path").dc2url_path
}

if ($ExistingPath) {
    $CleanRootPath = $ExistingPath -replace '\\exec$', ''
    $ProtocolStatus = "Not Registered"
    if (Test-Path "HKLM:\SOFTWARE\Classes\dc2URL" -or Test-Path "HKCU:\Software\Classes\dc2URL") {
        $ProtocolStatus = "Active (dc2URL://)"
    }
    
    # Render full Microsoft OS Environment Tracking Details
    Write-Host "`n[DETECTED] Pre-existing Installation Found on Microsoft Windows OS" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------"
    Write-Host "  Installation Directory : $CleanRootPath"
    Write-Host "  Binaries Subdirectory  : $ExistingPath"
    Write-Host "  Active Target Binary   : darkcom2.exe"
    Write-Host "  URI Protocol Status    : $ProtocolStatus"
    Write-Host "------------------------------------------------------------`n"
    
    $Prompt = Read-Host "Would you like to execute the uninstaller now to clean this instance? [Y/N]"
    if ($Prompt -ilike "Y*") {
        Write-Host "`n[INFO] Initializing system cleanup phase before fresh deployment..." -ForegroundColor Yellow
        
        # Pull down the single file uninstall block to execute the systemic flush
        $UninstallTemp = Join-Path $env:TEMP "dc2url_remote_uninstall.bat"
        $RemoteUninstallURL = "https://githubusercontent.com"
        
        Invoke-RestMethod -Uri $RemoteUninstallURL -OutFile $UninstallTemp
        if (Test-Path $UninstallTemp) {
            # Execute uninstaller with internal redirection override flag
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$UninstallTemp`" --from-installer" -Wait
            if (Test-Path $UninstallTemp) { Remove-Item $UninstallTemp -Force }
            exit
        }
    } else {
        Write-Host "[INFO] Aborting installation pipeline to prevent overlapping binary paths." -ForegroundColor Red
        exit
    }
}

# 2. Resolve Local Target Path If Clear
$DefaultRoot = Join-Path $env:ProgramFiles "dc2URL"
if (-not (Test-Path $env:ProgramFiles)) { $DefaultRoot = Join-Path $env:SystemDrive "Programs\dc2URL" }

Write-Host "Default installation path context: $DefaultRoot"
$TargetDir = Read-Host "Enter installation path or press ENTER to use default"
if ([string]::IsNullOrWhiteSpace($TargetDir)) { $TargetDir = $DefaultRoot }

# Provision clean scratch directory workspace trees
$TempDir = Join-Path $env:TEMP "dc2url_irm_scratch"
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force | Out-Null }
New-Item -ItemType Directory -Path (Join-Path $TempDir "exec") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TempDir "images") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TempDir "shell") -Force | Out-Null

# FIXED: Standardized raw githubusercontent routing matrix domain
$BaseURL = "https://githubusercontent.com"

# Fetch Root Level Objects Matrix
$RootFiles = @("install.bat", "uninstall.bat", "echo.bat", "favi-con.ico", "readme.MD")
foreach ($RF in $RootFiles) {
    Invoke-RestMethod -Uri "$BaseURL/$RF" -OutFile (Join-Path $TempDir $RF)
}

# Fetch Shell Folder Script Layout Modules
$ShellFiles = @("menu.bat", "git.bat", "copy.bat", "reg.bat")
foreach ($SF in $ShellFiles) {
    Invoke-RestMethod -Uri "$BaseURL/shell/$SF" -OutFile (Join-Path $TempDir "shell/$SF")
}

# Fetch Documentation Imagery Assets
Invoke-RestMethod -Uri "$BaseURL/images/cmd-src.png" -OutFile (Join-Path $TempDir "images/cmd-src.png")

# Fetch Core Compilations Binary Code
$BinFiles = @("darkcom2.exe", "DarkComHeadless.dll", "WebView2Loader.dll")
foreach ($BF in $BinFiles) {
    Invoke-RestMethod -Uri "$BaseURL/exec/$BF" -OutFile (Join-Path $TempDir "exec/$BF")
}

# Construct the transient transmediary configurations log file block
$IniFile = Join-Path $env:TEMP "dc2url_install.ini"
"[InstallationConfig]`nTargetDir=$TargetDir`nSourceMode=IRMFetched" | Out-File $IniFile -Encoding ASCII -Force

# Fire off the local orchestrator script block engine inside our scratch space layout context
Start-Process -FilePath "cmd.exe" -ArgumentList "/c cd /d `"$TempDir`" && install.bat --headless" -Wait

# Clear up local scratch path memory footprint
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force | Out-Null }
