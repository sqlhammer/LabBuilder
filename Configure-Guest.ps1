
#Tested with host Windows 10
#Tested with guest Windows Server 2016 CTP 4

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$ip,

   [Parameter(Mandatory=$True)]
   [string]$ADIPAddress,

   [Parameter(Mandatory=$True)]
   [string]$domainName,

   [Parameter(Mandatory=$True)]
   [string]$userName,

   [Parameter(Mandatory=$True)]
   [System.Security.SecureString]$password
)

.\Set-DemoGuestNetwork.ps1 -ipAddress $ip `
    -ADIPAddress $ADIPAddress

.\Set-DemoGuestMiscConfigs.ps1 -timezone "Eastern Standard Time"

# Domain cannot be contacted if attempted too soon after
# updating network adapters.
Start-Sleep -Seconds 10

.\Join-Domain.ps1 -domainName $domainName `
    -userName $userName `
    -password $password
