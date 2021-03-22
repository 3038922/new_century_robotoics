function installRARZIP($name, $url, $myPath) {
    #下载
    if (Test-Path($tmpPath + $name)) {
        Write-Host  $name" 已存在无需重新下载" -ForegroundColor Yellow
    }
    else {
        Write-Host "开始下载" $name -ForegroundColor Green
        $client.DownloadFile(('https://qzrobot.top/index.php/s/' + $url + '/download/' + $name), ($tmpPath + $name))
    }
    Start-Sleep -Milliseconds 200  # 延迟0.2秒
    $args = "x -ibck -y " + $tmpPath + $name + " $ncrRoboticsPath"
    Write-Host "开始解压缩" $name "参数" $args -ForegroundColor Green
    Start-Process  $winrar $args -Wait #解压缩zip
    #添加环境变量
    $EnvironmentPath = [environment]::GetEnvironmentVariable('Path', 'machine') # 获取环境变量
    if ($EnvironmentPath.split("; ") -Contains $myPath) {
        Write-Host "环境变量:" $myPath "已存在" -ForegroundColor yellow 
    }
    else {
        $EnvironmentPath += ($myPath + "; ")
        Write-Host "环境变量:" $myPath "已添加" -ForegroundColor green 
        [environment]::SetEnvironmentvariable("Path", $EnvironmentPath, "machine") #确认设置环境变量 user machine
    }
}


# 新世纪机器人社win10系统环境变量配置

Write-Host "此版本使用新世纪机器人学院(中国)安装源" -ForegroundColor Green
# powershell版本检查
$powershellVersion = $host.Version.ToString()
$ncrRoboticsPath = "c:\ncrRobotics\"
$tmpPath = $ncrRoboticsPath + "temp\"
if (!(Test-Path -Path $ncrRoboticsPath )) {
    Write-Host "创建ncrRobotics文件夹 $ncrRoboticsPath" -ForegroundColor Green
    & mkdir $ncrRoboticsPath 
}
if (!(Test-Path -Path $tmpPath)) {
    Write-Host "创建临时文件夹 $tmpPath" -ForegroundColor Green
    & mkdir $tmpPath
}
if ($powershellVersion -ge "5.0.0.0") {
    #下载wirar
    $client = new-object System.Net.WebClient #创建下载对象
    if (Test-Path("C:\Program Files\WinRAR\WinRAR.exe")) {
        Write-Host "winrar.exe 已存在无需重新下载" -ForegroundColor Green
    }
    else {
        Write-Host "开始下载winrar.exe" -ForegroundColor Green
        $client.DownloadFile('https://qzrobot.top/index.php/s/EgsQdNJzZKjrGCz/download/WinRAR.exe', $tmpPath + 'winrar.exe')
        Start-Sleep -Milliseconds 200  # 延迟0.2秒
        Write-Host "开始安装winrar.exe" -ForegroundColor Green
        Invoke-Expression($tmpPath + "winrar.exe /S /v /qn") 
    }
    # 必备软件安装检查
    $soft =
    @{name = 'code.exe'; url = 'GjQZgGKfBDw2FBW'; args = ' /VERYSILENT /mergetasks=!runcode.desktopicon /ALLUSERS' },
    @{name = 'git.exe'; url = 'afkWMfGGrZxZcaR'; args = ' /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /ALLUSERS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"' },
    @{name = 'python.exe'; url = 'THniMLtpTa4j3j5'; args = ' /quiet InstallAllUsers=1 PrependPath=1 Include_test=0' }
    foreach ($it in $soft) {
        $name = $it.name.Substring(0, $it.name.IndexOf('.')) 
        Write-Host "正在检查 $name 是否安装"  -ForegroundColor Green
        $p = Invoke-Expression($name + " --version") 2>&1
        if ([String]::IsNullOrEmpty($p)) {
            Write-Host $it.name "没有安装或者环境变量没有添加"-ForegroundColor Red
            Write-Host "开始下载" $it.name -ForegroundColor Yellow
            $client.DownloadFile(('https://qzrobot.top/index.php/s/' + $it.url + '/download/' + $it.name), ($tmpPath + $it.name))
            Start-Sleep -Milliseconds 200  # 延迟0.2秒
            Write-Host '开始安装' $it.name -ForegroundColor Green
            Start-Process ($tmpPath + $it.name ) $it.args -Wait #执行安装
        }
        else {
            Write-Host $p -ForegroundColor Green
        }
    }
    #下载各种压缩包
    $zip =
    @{name = 'cmake.rar'; url = '6bAiQPsa497goAe'; path = ($ncrRoboticsPath + "CMake\bin") },
    @{name = 'ninja.rar'; url = 'dcSrTgns6qEfDw8'; path = ($ncrRoboticsPath + "ninja") },
    @{name = 'LLVM.rar'; url = '8ZE2KoQLYSEqrpa'; path = ($ncrRoboticsPath + "llvm\Release\bin") },
    @{name = 'ccls.rar'; url = '36qwxFrbbpydBJS'; path = ($ncrRoboticsPath + "ccls\Release") },
    @{name = 'PROS.zip'; url = 'PSbyBdMJ2Ti8ZT8'; path = ($ncrRoboticsPath + "PROS\toolchain\usr\bin") }
    $winrar = "C:\Program Files\WinRAR\winrar.exe"
    foreach ($it in $zip) {
        $name = $it.name.Substring(0, $it.name.IndexOf('.')) 
        Write-Host "正在检查 $name 是否安装"  -ForegroundColor Green
        if (Test-Path ($ncrRoboticsPath + $name)) {
            if ((Read-Host ("是否更新" + $it.name + "?[Y/N]")) -eq 'y') {
                Write-Host "检测到 $name 文件夹已经存在, 正在删除" -ForegroundColor Yellow
                Remove-Item ($ncrRoboticsPath + $name) -recurse -force
                installRARZIP -name $it.name -url $it.url -myPath $it.path 
            }
        }
        else {
            installRARZIP -name $it.name -url $it.url -myPath $it.path 
        }
    }
    # pros_toolchain设置
    Write-Host "正在设置prosToolchain路径" -ForegroundColor Green
    $prosToolchainPath = "$ncrRoboticsPath\PROS\toolchain\usr"
    [environment]::SetEnvironmentvariable("PROS_TOOLCHAIN", $prosToolchainPath, "machine") #设置环境变量 user machine

    #安装PROS工具链
    Write-Host "正在检查pros-cli是否安装"  -ForegroundColor Green
    $p = & { pros --version } 2>&1
    if ($p -is [System.Management.Automation.ErrorRecord]) {
        Write-Host "pros-cli没有安装或者环境变量没有添加, 开始安装" -ForegroundColor yellow
        & pip.exe install --upgrade pros-cli -i https://mirrors.aliyun.com/pypi/simple/
    }
    else {
        Write-Host  $p -ForegroundColor Green
    }
    Write-Host  "正在安装vscode插件 setting sync" -ForegroundColor Green
    & code.exe --install-extension shan.code-settings-sync 
    Write-Host "正在删除临时下载存放文件夹"  -ForegroundColor Green
    # Remove-Item $tmpPath\ -recurse -force
    Write-Host "恭喜安装成功"  -ForegroundColor Green
}
else {
    Write-Host "powershell当前版本为:$powershellVersion, 请升级powershell至于5.x以上" -ForegroundColor Red
}












