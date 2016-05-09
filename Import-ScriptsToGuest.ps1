
param
(
    [Parameter(Mandatory=$true)]
    [string] $serverName,

    [Parameter(Mandatory=$true)]
    [string] $VHDPath,

    [Parameter(Mandatory=$true)]
    [string] $scriptsPath,

    [Parameter(Mandatory=$false)]
    [switch]$startVMAfter
)

$ErrorActionPreference = 'Stop'

$vm = Get-VM -Name $serverName

if($vm.State -ine 'off')
{
    $vm | Stop-VM -Force
}

$splitArray = $VHDPath.Split(".");
$extension = $splitArray[$splitArray.Count-1];

function Get-DriveLetter($obj)
{
    return ($obj | 
            Get-Disk | 
            Get-Partition | 
            Get-Volume | 
            Where-Object { $_.FileSystemLabel -ine 'System Reserved' }).DriveLetter
}

if((Get-DiskImage -ImagePath $VHDPath).Attached -eq $false)
{
    $driveLetter = Get-DriveLetter (Mount-VHD –Path $VHDPath –PassThru)
}
else
{
    $driveLetter = Get-DriveLetter (Get-DiskImage -ImagePath $VHDPath)
}

$guestScriptsPath = "$driveLetter`:\Scripts"

if(-not (Test-Path $guestScriptsPath)) { New-Item $guestScriptsPath -ItemType Directory }

Copy-Item $scriptsPath $guestScriptsPath -Recurse -Force

Dismount-DiskImage -ImagePath $VHDPath

if(($vm.State -ine 'running') -and $startVMAfter)
{
    $vm | Start-VM
}

