# 查询并删除 HKEY_CURRENT_USER\SOFTWARE\PremiumSoft\NavicatPremium 下的所有 Update 键值
Write-Output "清空了: HKEY_CURRENT_USER\SOFTWARE\PremiumSoft\NavicatPremium\Update"
Remove-ItemProperty -Path "HKCU:\SOFTWARE\PremiumSoft\NavicatPremium\Update" -Name * -Force

# 查询并删除 HKEY_CURRENT_USER\SOFTWARE\PremiumSoft\NavicatPremium 下的所有 Registration 键
Get-ChildItem -Path "HKCU:\SOFTWARE\PremiumSoft\NavicatPremium" -Recurse | Where-Object { $_.Name -match "Registration" } | ForEach-Object {
    Write-Output "清空了: $($_.PSPath)"
    Remove-ItemProperty -Path $_.PSPath -Name * -Force
}

# 查询并删除 HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID 下的所有包含 Info 键的文件夹
Get-ChildItem -Path "HKCU:\SOFTWARE\Classes\CLSID" | ForEach-Object {
    $clisdKey = $_.PSPath
    $infoKeys = Get-ChildItem -Path $clisdKey -Recurse | Where-Object { $_.Name -match "Info" }
    $infoKeys | ForEach-Object {
        Write-Output "删除了: $clisdKey"
        Remove-Item -Path $clisdKey -Recurse -Force
    }
}

# 查询并删除 HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID 下符合条件同时包含 DefaultIcon 和 ShellFolder 键值都为空的文件夹

# 获取所有 CLSID 项
$clsidItems = Get-ChildItem -Path "HKCU:\Software\Classes\CLSID"

foreach ($item in $clsidItems) {
    $clsidPath = $item.PSPath
    $subItems = Get-ChildItem -Path $clsidPath -Recurse

    # 检查是否存在 DefaultIcon 和 ShellFolder
    $hasDefaultIcon = $false
    $hasShellFolder = $false

    foreach ($subItem in $subItems) {
        if ($subItem.Name -match "DefaultIcon") {
            $hasDefaultIcon = $true
        }
        if ($subItem.Name -match "ShellFolder") {
            $hasShellFolder = $true
        }
    }

    # 如果同时存在 DefaultIcon 和 ShellFolder
    if ($hasDefaultIcon -and $hasShellFolder) {
        if ((($subItems.Name[0] -match "DefaultIcon|ShellFolder") -and ($subItems.Name[1] -match "DefaultIcon|ShellFolder")) -and (($subItems.Property -eq $null))){
            Write-Output "删除了: $clsidPath"
            Remove-Item -Path $clsidPath -Recurse -Force
        }
    }
}

# 暂停脚本执行，等待用户按任意键继续
Write-Host "请按任意键继续..."
$null = [System.Console]::ReadKey()

# 退出脚本
exit
