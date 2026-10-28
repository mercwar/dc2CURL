<#
.synopsis
    dc2url root staging loader
    aifvs-artifact
#>

[cmdletbinding()]
param(
    [string]$sound = ""
)

$erroractionpreference = "stop"

try {
    [net.servicepointmanager]::securityprotocol = [net.securityprotocoltype]::tls12
}
catch {
}

# ============================================================================
# sound processing
# ============================================================================

$soundval = "off"

if ($sound -ceq "on") {
    $soundval = "on"
}

# ============================================================================
# console setup
# ============================================================================

try {
    $host.ui.rawui.windowtitle = "dc2url launcher v1.0"

    $host.ui.rawui.buffersize = `
        new-object system.management.automation.host.size(100,40)

    $host.ui.rawui.windowsize = `
        new-object system.management.automation.host.size(100,40)
}
catch {
}

# ============================================================================
# configuration
# ============================================================================


$RepoUrl = "https://raw.githubusercontent.com/mercwar/dc2URL/main/launcher.bat"

$tempinstaller = join-path `
    $env:temp `
    ("dc2_install_{0}.bat" -f ([guid]::newguid().tostring("n").substring(0,8)))

# ============================================================================
# banner
# ============================================================================

clear-host

write-host "====================================================================================" -foregroundcolor darkgray
write-host "     e c l i p s e    i n s t a l l e r    ■    d c 2 u r l    k e r n e l" -foregroundcolor cyan
write-host "     stargate 2 quasar 19" -foregroundcolor cyan
write-host "====================================================================================" -foregroundcolor darkgray
write-host "  mercwar stargate technology" -foregroundcolor darkyellow
write-host "  status: contacting server..." -foregroundcolor gray
write-host "====================================================================================" -foregroundcolor darkgray
write-host ""

write-host "  [system] sound mode = $soundval" -foregroundcolor cyan
write-host ""

write-host "  [avis] searching for installation gateway" -foregroundcolor yellow

write-host "  [avis] » target source : " -nonewline -foregroundcolor darkgray
write-host $repourl -foregroundcolor white

write-host "  [avis] » target output : " -nonewline -foregroundcolor darkgray
write-host $tempinstaller -foregroundcolor white

write-host ""
write-host "  [avis] connecting to gateway via dc2url..." -foregroundcolor cyan

# ============================================================================
# download launcher
# ============================================================================

try {

    $dc2check = get-command dc2url -erroraction silentlycontinue

    if ($dc2check) {

        dc2url -o $tempinstaller $repourl

    }
    else {

        $webclient = new-object system.net.webclient
        $webclient.downloadfile($repourl, $tempinstaller)

    }

    if (-not (test-path $tempinstaller)) {
        throw "download failed. launcher missing."
    }

    if ((get-item $tempinstaller).length -eq 0) {
        throw "download failed. launcher empty."
    }

    $fileheader = get-content `
        $tempinstaller `
        -totalcount 5 `
        -erroraction silentlycontinue |
        out-string

    if ($fileheader -match '<!doctype|<html') {
        throw "server returned html instead of launcher.bat"
    }

}
catch {

    write-host ""
    write-host "  [avis error] $_" -foregroundcolor red
    write-host ""

    pause

    exit 1
}

write-host ""
write-host "  [avis success] payload secured on disk." -foregroundcolor green
write-host ""

# ============================================================================
# pre execution
# ============================================================================

write-host "  [avis eclipse] searching for cyborg launcher..." -foregroundcolor darkgray

start-sleep -seconds 3

write-host ""
write-host "  [avis] calling portal installer" -foregroundcolor yellow
write-host "  [eclipse] » avis reported success..." -foregroundcolor darkgray
write-host "====================================================================================" -foregroundcolor darkgray
write-host ""

start-sleep -milliseconds 600

# ============================================================================
# execute launcher with sound argument
# ============================================================================

write-host "  [debug] sound argument = [$soundval]" -foregroundcolor yellow

# FIX: Literal outer single quotes protect the internal double quotes.
# This prevents the script block compiler from crashing on line 162.
$fullCommandLine = '/c "call "' + $tempinstaller + '" ' + $soundval + '"'

write-host "  [debug] command line   = cmd.exe $fullCommandLine" -foregroundcolor yellow
write-host ""

start-process `
    -filepath "cmd.exe" `
    -argumentlist $fullCommandLine `
    -wait `
    -nonewwindow

# ============================================================================
# cleanup
# ============================================================================

if (test-path $tempinstaller) {

    remove-item `
        $tempinstaller `
        -force `
        -erroraction silentlycontinue
}

# ============================================================================
# completion
# ============================================================================

write-host ""
write-host "  [eclipse] dc2url will be visible in add/remove programs after registration." -foregroundcolor green
write-host "  [eclipse] auto updates are not supported at this time." -foregroundcolor green
write-host "  [eclipse] run this installer again at any time to update dc2url." -foregroundcolor green
write-host "====================================================================================" -foregroundcolor darkgray
