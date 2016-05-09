
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$False)]
   [string]$timezone = "Eastern Standard Time"
)

$ErrorActionPreference = "stop"

Import-Module NetAdapter

Set-NetFirewallProfile -All -Enabled False

function Set-TimeZone([string]$tz)
{
    tzutil.exe /s $tz
    $LASTEXITCODE -eq 0
}

Set-TimeZone $timezone

