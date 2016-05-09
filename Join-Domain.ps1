
param
(
    [Parameter(Mandatory=$true)]
    [string]$domainName,

    [Parameter(Mandatory=$true)]
    [string]$userName,

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]$password
)

$error.Clear();

$cred = New-Object System.Management.Automation.PsCredential($userName, $password)

Add-Computer -DomainName $domainName -Credential $cred

if($error.Count -gt 0) { return; } #Let me see the error before reboot

Restart-Computer -Force

