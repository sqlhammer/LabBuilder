
#Tested with host Windows 10
#Tested with guest Windows Server 2016 CTP 4

param
(
    [Parameter(Mandatory=$true)]
    [string]$serverName,

    [Parameter(Mandatory=$true)]
    [string]$ip,

    [Parameter(Mandatory=$true)]
    [string]$domainName,

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]$password
)

.\Set-DemoGuestNetwork.ps1 -serverName $serverName `
    -ipAddress $ip

.\Set-DemoGuestMiscConfigs.ps1 -timezone "Eastern Standard Time"

.\Sysprep-VM.ps1

.\New-ADDomainController.ps1 -domainname $domainName `
    -password $password 
