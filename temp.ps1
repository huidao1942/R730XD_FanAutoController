# 定义IDRAC的IP地址、用户名和密码
$IDRAC_IP = 'idrac的ip地址'
$USERNAME = '用户名'
$PASSWORD = '密码'

# 函数：获取GPU温度
function Get-GpuTemperature {
    $result = & nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
    if ($LASTEXITCODE -eq 0) {
        return [float]($result.Trim())
    } else {
        Write-Output '获取显卡温度失败'
        return $null
    }
}

# 函数：设置风扇速度
function Set-FanSpeed([int]$speed) {
    if ($speed -ge 100 -or $speed -le 10) {
        Write-Output "非法操作风扇"
    } else {
        $hexSpeed = '{0:x2}' -f $speed
        $args = @('-I', 'lanplus', '-H', $IDRAC_IP, '-U', $USERNAME, '-P', $PASSWORD, 'raw', '0x30', '0x30', '0x02', '0xff', "0x$hexSpeed")
        $result = & ipmitool @args 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "风扇转速调整至 $($speed)%"
        } else {
            Write-Output "风扇转速调整失败：: $result"
        }
    }
}

# 主函数：循环监控GPU温度并调整风扇速度
while ($true) {
    $gpuTemp = Get-GpuTemperature
    if ($gpuTemp -ne $null) {
        Write-Output "显卡温度为: $($gpuTemp)°C"
        if ($gpuTemp -gt 80) {
            Set-FanSpeed -speed 80
        } elseif ($gpuTemp -gt 75) {
            Set-FanSpeed -speed 70
        } elseif ($gpuTemp -gt 70) {
            Set-FanSpeed -speed 60
        } elseif ($gpuTemp -gt 60) {
            Set-FanSpeed -speed 50
        } elseif ($gpuTemp -gt 45) {
            Set-FanSpeed -speed 35
        } else {
            Set-FanSpeed -speed 20
        }
    }
    Start-Sleep -Seconds 5 # 每5秒检查一次
}
