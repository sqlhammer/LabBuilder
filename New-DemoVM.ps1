
[CmdletBinding(DefaultParameterSetName='None')]
Param(
   [Parameter(Mandatory=$True)]
   [string]$serverName,

   [Parameter(Mandatory=$True)]
   [string]$project,

   [Parameter(ParameterSetName='OSFromISO',Mandatory=$true)]
   [switch]$OSFromISO,

   [Parameter(ParameterSetName='TemplateVHD',Mandatory=$true)]
   [ValidateSet("2012","2016")]
   [string]$OSVersion,

   [Parameter(ParameterSetName='TemplateVHD',Mandatory=$true)]
   [switch]$TemplateVHD,

   [Parameter(Mandatory=$false)]
   [switch]$startVMAfterBuild
)

$sw = [System.Diagnostics.Stopwatch]::StartNew();

Import-Module Hyper-V

$ErrorActionPreference = "stop"

[long] $diskSize = 60GB #only necessary if OSFromISO is false

[long] $startupMemory = 1GB
[long] $minMemory = 512MB
[long] $maxMemory = 4GB
[int] $memoryBufferPercentage = 20
$vCPUCount = 4

[string] $VMSwitchName = "InternalSwitch"

function Select-Template([string]$OSVersion)
{
    switch ($OSVersion)
    {
        "2012" {return "WindowsServer2012R2.vhd"}
        "2016" {return "Win2016CTP4-2.vhdx"}
    }
}

#[string] $templateDir = "\\HAMMERNAS\InstallMedia"
[string] $templateDir = "E:\VMs\Hyper-V\Templates"
[string] $templateName = Select-Template $OSVersion
[string] $template = Join-Path $templateDir $templateName

[string] $VMdir = "E:\VMs\Hyper-V"
[string] $projectDir = Join-Path $VMdir $project
[string] $serverPath = Join-Path $projectDir $servername
[string] $VHDExtension = ($templateName.Split("."))[1]
[string] $VHDName = "$servername.$VHDExtension"
[string] $VHDPath = Join-Path $serverPath $VHDName

if(-not (Test-Path $projectDir)) { New-Item $projectDir -ItemType Directory }
if(-not (Test-Path $serverPath)) { New-Item $serverPath -ItemType Directory }

if($OSFromISO)
{
    New-VM –Name $serverName `
        –MemoryStartupBytes $startupMemory `
        –NewVHDPath $VHDPath `
        -Path $serverPath `
        -NewVHDSizeBytes $diskSize 
}

if($TemplateVHD)
{
    Copy-Item -Path $template -Destination $VHDPath

    New-VM –Name $serverName `
        –MemoryStartupBytes $startupMemory `
        –VHDPath $VHDPath `
        -Path $serverPath 
}

Get-VM -Name $serverName | Set-VM -AutomaticStartAction Nothing

Set-VMProcessor -VMName $serverName -Count $vCPUCount

Set-VMMemory -VMName $serverName `
    -DynamicMemoryEnabled $true `
    -MinimumBytes $minMemory `
    -MaximumBytes $maxMemory `
    -StartupBytes $startupMemory `
    -Buffer $memoryBufferPercentage

#I'm assuming that a new VM always only has 1 adapter
$networkAdapterName = (Get-VMNetworkAdapter -VMName $serverName).Name

Connect-VMNetworkAdapter -VMName $serverName `
    -Name $networkAdapterName `
    -SwitchName $VMSwitchName

if($startVMAfterBuild)
{
    Start-VM $serverName
}

#TODO: If -not $OSFromISO, manually mount os ISO from local computer (no UNC)
#TODO: If -not $OSFromISO, manually install OS
#TODO: copy Set-DemoGuestNetwork and Set-DempGuestMiscConfigs to the VM by
#        mounting the VHD on Host and copying to desktop.

$sw | fl *


