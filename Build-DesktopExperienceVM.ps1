
#Tested with host Windows 10
#Tested with guest Windows Server 2016 CTP 4

param
(
    [Parameter(Mandatory=$false)]
    [string]$poshDir = (Get-Location).ToString(),

    [Parameter(Mandatory=$true)]
    [string]$serverName,

    [Parameter(Mandatory=$true)]
    [string]$projectName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Template","ISO")]
    [string]$buildType
)

$ErrorActionPreference = 'stop'
Set-Location $poshDir

.\Enable-HyperV.ps1

if(Get-VM | Where-Object { $_.Name -ieq $serverName })
{
    throw "Virtual machine '$serverName' already exists in Hyper-V!"
    return;
}

if($buildType -ieq "ISO")
{
    .\New-DemoVM.ps1 -serverName $serverName `
        -project $projectName `
        -OSFromISO 
}

if($buildType -ieq "Template")
{
    .\New-DemoVM.ps1 -serverName $serverName `
        -project $projectName `
        -TemplateVHD `
        -OSVersion 2016
}

$VHDPath = (Get-VM -VMName $serverName | 
            Select-Object VMId | 
            Get-VHD).Path

.\Import-ScriptsToGuest.ps1 -serverName $serverName `
    -VHDPath $VHDPath `
    -scriptsPath $poshDir `
    -startVMAfter

