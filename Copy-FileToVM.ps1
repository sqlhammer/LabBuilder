
$password = ConvertTo-SecureString "MG7eng22@@@" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential (".\Administrator", $password )
$source = "C:\Users\Derik\OneDrive\DemoAutomation"
$destination = "Z:\"
$destDir = "\\192.168.10.10\C$\Users\Administrator\desktop"

New-PSDrive -Name Z -PSProvider FileSystem -Root $destDir -Credential $cred
Copy-Item $source $destination

