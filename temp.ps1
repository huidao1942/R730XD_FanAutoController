# ����IDRAC��IP��ַ���û���������
$IDRAC_IP = '192.168.5.253'
$USERNAME = 'root'
$PASSWORD = 'Qq1293258904..'

# ��������ȡGPU�¶�
function Get-GpuTemperature {
    $result = & nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
    if ($LASTEXITCODE -eq 0) {
        return [float]($result.Trim())
    } else {
        Write-Output '��ȡ�Կ��¶�ʧ��'
        return $null
    }
}

# ���������÷����ٶ�
function Set-FanSpeed([int]$speed) {
    if ($speed -ge 100 -or $speed -le 10) {
        Write-Output "�Ƿ���������"
    } else {
        $hexSpeed = '{0:x2}' -f $speed
        $args = @('-I', 'lanplus', '-H', $IDRAC_IP, '-U', $USERNAME, '-P', $PASSWORD, 'raw', '0x30', '0x30', '0x02', '0xff', "0x$hexSpeed")
        $result = & ipmitool @args 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Output "����ת�ٵ����� $($speed)%"
        } else {
            Write-Output "����ת�ٵ���ʧ�ܣ�: $result"
        }
    }
}

# ��������ѭ�����GPU�¶Ȳ����������ٶ�
while ($true) {
    $gpuTemp = Get-GpuTemperature
    if ($gpuTemp -ne $null) {
        Write-Output "�Կ��¶�Ϊ: $($gpuTemp)��C"
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
    Start-Sleep -Seconds 5 # ÿ5����һ��
}