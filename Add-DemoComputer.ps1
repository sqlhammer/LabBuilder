

$password = ConvertTo-SecureString "MG7eng22@@@" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PsCredential("SQLHammer\Derik", $password)
Add-Computer -DomainName "sqlhammer.demo" -Credential $cred

