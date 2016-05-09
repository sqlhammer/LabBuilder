
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$domainname,
	
   [Parameter(Mandatory=$True)]
   [string]$domainUserName,

   [Parameter(Mandatory=$True)]
   [Security.SecureString]$password   
)

Import-Module ActiveDirectory

New-ADUser -SamAccountName $domainUserName `
    -Name $domainUserName `
    -UserPrincipalName "$domainUserName@$domainname" `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true 

Add-ADGroupMember 'Domain Admins' $domainUserName
