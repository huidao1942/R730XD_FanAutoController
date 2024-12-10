import subprocess
import time

IDRAC_IP = 'idracip地址'
USERNAME = 'idrac用户名'
PASSWORD = 'idrac密码'

def get_gpu_temperature():
    result = subprocess.run(['nvidia-smi', '--query-gpu=temperature.gpu', '--format=csv,noheader'], capture_output=True, text=True)
    if result.returncode == 0:
        return float(result.stdout.strip())
    else:
        print('获取显卡温度失败')
        return None

def set_fan_speed(speed):
    if speed >= 100 or speed <= 10:
        print("非法操作风扇")
    else:
        result = subprocess.run(['ipmitool', '-I', 'lanplus', '-H', IDRAC_IP, '-U', USERNAME, '-P', PASSWORD, 'raw', '0x30', '0x30', '0x02', '0xff', f'0x{speed:02x}'], capture_output=True, text=True)
        #print(f'执行IPMI调速命令: {" ".join(result.args)}')
        if result.returncode == 0:
            print(f'风扇转速调整至 {speed}%')
        else:
            print(f'风扇转速调整失败：: {result.stderr}')

def main():
    while True:
        gpu_temp = get_gpu_temperature()
        if gpu_temp is not None:
            print(f'显卡温度为: {gpu_temp}°C')
            if gpu_temp > 80:
                set_fan_speed(80)
            elif gpu_temp > 75:
                set_fan_speed(70)
            elif gpu_temp > 70:
                set_fan_speed(60)
            elif gpu_temp > 60:
                set_fan_speed(50)
            elif gpu_temp > 45:
                set_fan_speed(35)
            else:
                set_fan_speed(20)
        time.sleep(5) # 每5秒检查一次

if __name__ == '__main__':
    main()
