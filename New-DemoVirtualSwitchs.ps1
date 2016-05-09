
$ErrorActionPreference = "continue"

Import-Module Hyper-V
Import-Module NetAdapter

$IPBase = "192.168.10.{0}"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$IPType = "IPv4"

#<#
Get-NetAdapter | ft Name

$ethernetName = Read-Host "What is the name of your ethernet connection? "
$wifiName = Read-Host "What is the name of your Wi-Fi connection? "
#>

<#debugging
$ethernetName = "Local Area Connection"
$wifiName = "Wireless Network Connection"
#>

$ethernet = Get-NetAdapter -Name $ethernetName
$wifi = Get-NetAdapter -Name $wifiName

function Set-IPAddress ([string] $SwitchName, [string] $leastSignificantBit)
{
    $adapter = Get-NetAdapter -Name "*$SwitchName*"
    
    If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }

    If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }

    $adapter | Set-NetIPInterface -Dhcp disabled
    
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress (($IPBase).Replace("{0}",$leastSignificantBit)) `
        -PrefixLength $MaskBits |
        Out-Null

}

if(-not (Get-VMSwitch | Where-Object { $_.Name -ieq "ExternalSwitch" }))
{
    New-VMSwitch -Name ExternalSwitch `
        -NetAdapterName $ethernet.Name `
        -AllowManagementOS $true `
        -Notes ‘Parent OS, VMs, LAN’
}

Set-IPAddress ExternalSwitch 2

<# broken, not sure why
if(-not (Get-VMSwitch | Where-Object { $_.Name -ieq "WiFiExternalSwitch" }))
{
    New-VMSwitch -Name WiFiExternalSwitch `
        -NetAdapterName $wifi.Name `
        -AllowManagementOS $true `
        -Notes ‘Parent OS, VMs, wifi’
}

#Set-IPAddress WiFiExternalSwitch 3
#>

if(-not (Get-VMSwitch | Where-Object { $_.Name -ieq "PrivateSwitch" }))
{
    New-VMSwitch -Name PrivateSwitch `
        -SwitchType Private `
        -Notes ‘Internal VMs only’
}

if(-not (Get-VMSwitch | Where-Object { $_.Name -ieq "InternalSwitch" }))
{
    New-VMSwitch -Name InternalSwitch `
        -SwitchType Internal `
        -Notes ‘Parent OS, and internal VMs’
}

Set-IPAddress InternalSwitch 1

