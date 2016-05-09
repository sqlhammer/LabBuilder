
#Protecting my dumb self
if($env:computername -ieq "SQLHAMMERLAPTOP")
{
    Write-Error "DO NOT SYSPREP YOUR LAPTOP, SYSPREP YOUR VM!"
    return
}

$exePath = "$env:windir\System32\Sysprep\sysprep.exe"
$args = '/generalize /shutdown /oobe'

#Can you tell I'm scared of this script?
#This if is totally unnecessary.
if($env:computername -ine "SQLHAMMERLAPTOP")
{
    Start-Process -FilePath $exePath -ArgumentList $args
}

