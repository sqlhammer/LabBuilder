
param
(
    [Parameter(Mandatory=$true)]
    [string]$serverName,

    [Parameter(Mandatory=$true)]
    [string]$domainName,

    [Parameter(Mandatory=$true)]
    [string]$domainUserName,

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]$password
)

.\New-DemoDomainAdmin.ps1 -domainname $domainName `
    -password $password `
    -domainUserName $domainUserName

Rename-Computer -NewName $serverName -Force
Restart-Computer -Force
