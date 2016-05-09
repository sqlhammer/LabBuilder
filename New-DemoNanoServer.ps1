
Import-Module 'C:\Users\Derik\OneDrive\DemoAutomation\NanoServerScripts\NanoServerImageGenerator.psm1'

cd "C:\users\Derik\OneDrive\DemoAutomation\NanoServer\"
.\Convert-WindowsImage.ps1 -WIM 'C:\Users\Derik\OneDrive\Demo Aut
omation\NanoServer\NanoServer.wim' -VHD 'C:\Users\Derik\OneDrive\DemoAutomation\NanoServer\ClusterNanoServer.vhdx' -VHD
Format VHDX -SizeBytes 10GB -Edition 2 -DiskLayout UEFI

$serverName = "SQL-Win2016-1"
$project = "BasicHA"
$password = ConvertTo-SecureString "MG7eng22@@@" -AsPlainText -Force

$VMdir = "E:\VMs\Hyper-V"
$projectDir = Join-Path $VMdir $project
$serverPath = Join-Path $projectDir $servername
$nanoBasePath = Join-Path $serverPath "NanoBase"
$VHDExtension = "vhdx"
$VHDName = "$servername.$VHDExtension"
$VHDPath = Join-Path $serverPath $VHDName

$MediaPath = "\\HAMMERNAS\InstallMedia"
$MediaName = "WindowsServer2016_CTP4_X64FRE_EN-US.ISO"
$MediaPath = Join-Path $MediaPath $MediaName

$mountResult = Mount-DiskImage $MediaPath -PassThru
$mountedDriveLetter = ($mountResult | Get-Volume).DriveLetter

$MediaPath = "$mountedDriveLetter`:\"

if(-not (Test-Path $projectDir)) { New-Item $projectDir -ItemType Directory }
if(-not (Test-Path $serverPath)) { New-Item $serverPath -ItemType Directory }
if(-not (Test-Path $nanoBasePath)) { New-Item $nanoBasePath -ItemType Directory }

#<#
New-NanoServerImage `
    -MediaPath $MediaPath `
    -BasePath "ClusterNanoServer.vhdx" ` #$nanoBasePath `
    -TargetPath $VHDPath `
    -ComputerName $serverName `
    -OEMDrivers `
    -AdministratorPassword $password `
    -Clustering 
#>

$mountResult | Dismount-DiskImage

