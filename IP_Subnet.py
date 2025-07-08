import ipaddress
from collections import defaultdict

lst = ['8.8.8.1', '8.8.8.2', '8.8.8.3', '8.8.8.4', '8.8.8.5', '8.8.8.6', '8.8.8.7', '8.8.8.8', '8.8.8.9', '8.8.8.10'] 

subnets = [ipaddress.ip_network('8.8.8.8/22'), ipaddress.ip_network('9.9.9.9/22')]

cnt = defaultdict(int)
outside = []

for ip in lst:
    ip_obj = ipaddress.ip_address(ip)
    found = False
    for subnet in subnets:
        if ip_obj in subnet:
            cnt[subnet] += 1
            found = True
            break
    if not found:
        outside.append(ip)

print("📊 Распределение IP по подсетям:")
for subnet, count in cnt.items():
    print(f"🔹 {subnet}: {count} IP")

print("\n❌ IP вне подсетей (всего {}):".format(len(outside)))
for ip in outside:
    print(f"  - {ip}")
_____________________________________

📊 Распределение IP по подсетям:
🔹 8.8.0.0/22: 6 IP
🔹 9.9.0.0/22: 2 IP

❌ IP вне подсетей (всего 2):
  - 10.10.0.9
  - 10.10.0.10
