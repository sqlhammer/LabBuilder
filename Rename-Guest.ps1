
#Tested with host Windows 10
#Tested with guest Windows Server 2016 CTP 4

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$newServerName
)

$Error.Clear();

Rename-Computer -NewName $newServerName -Force

if($error.Count -gt 0) { return; } #Let me see the error before reboot

Restart-Computer -Force
