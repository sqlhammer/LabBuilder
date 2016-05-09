
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$domainname,
	
   [Parameter(Mandatory=$True)]
   [string]$password
)

Add-WindowsFeature -Name "ad-domain-services” -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "dns” -IncludeAllSubFeature -IncludeManagementTools 
Add-WindowsFeature -Name "gpmc” -IncludeAllSubFeature -IncludeManagementTools

$domainname = "sqlhammer.demo"
$netbiosName = ($domainname.Split('.'))[0]
$password = ConvertTo-SecureString $password -AsPlainText -Force

Import-Module ADDSDeployment 

#TODO: fix | it requests the domain name, safe mode pw, and confirmation
Install-ADDSForest -CreateDnsDelegation:$false ` 
    -DatabasePath "C:\Windows\NTDS" ` 
    -DomainMode Win2012 ` 
    -DomainName $domainname ` 
    -DomainNetbiosName $netbiosName ` 
    -ForestMode Win2012 ` 
    -InstallDns:$true ` 
    -LogPath "C:\Windows\NTDS" ` 
    -NoRebootOnCompletion:$false ` 
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $password `
    -Force

