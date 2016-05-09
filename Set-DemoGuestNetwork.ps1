
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$ipAddress,

   [Parameter(Mandatory=$False)]
   [string]$ADIPAddress
)

$ErrorActionPreference = "stop"

Import-Module NetAdapter

$MaskBits = 24 # This means subnet mask = 255.255.255.0
$IPType = "IPv4"
if($ADIPAddress)
{
    $VirtualSwitchIP = $ADIPAddress
}
else
{
    $VirtualSwitchIP = "192.168.10.1"
}

function Set-IPAddress ([string] $leastSignificantBit)
{
    #Assumes only 1 network adapter
    $adapter = Get-NetAdapter
    
    If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }

    If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }

    $adapter | Set-NetIPInterface -Dhcp disabled
    
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress $ipAddress `
        -PrefixLength $MaskBits `
        -DefaultGateway $VirtualSwitchIP |
        Out-Null

    $adapter | Set-DnsClientServerAddress -ServerAddresses $VirtualSwitchIP

}

Set-IPAddress



