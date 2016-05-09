
#mixed domain pre-setup (exec on local and remote server)
<#
New-Itemproperty -name LocalAccountTokenFilterPolicy -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -propertyType DWord -value 1
Set-item wsman:localhost\client\trustedhosts -value 192.168.10.10 -Force
#>

#<#
$password = ConvertTo-SecureString "MG7eng22@@@" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("SQLHammer\Administrator", $password )
Enter-PSSession 192.168.10.10 -Credential $cred
#>

#Code here


Exit-PSSession


