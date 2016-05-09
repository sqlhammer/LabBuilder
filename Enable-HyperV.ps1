
Get-WindowsOptionalFeature -Online -FeatureName *hyper-v*all |
    Where-Object { $_.State -ine "enabled" } |
    Enable-WindowsOptionalFeature –Online
