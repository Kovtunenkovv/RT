import ipaddress
from collections import defaultdict

lst = ['8.8.0.1', '8.8.0.2', '8.8.0.3', '8.8.0.4', '8.8.0.5', '8.8.0.6', '9.9.0.7', '9.9.0.8', '10.10.0.9', '10.10.0.10'] 

subnets = [ipaddress.ip_network('8.8.0.0/22'), ipaddress.ip_network('9.9.0.0/22')]

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

print("📊 IP Subnet Distribution:")
for subnet, count in cnt.items():
    print(f"🔹 {subnet}: {count} IP")

print("\n❌ Unclassified IPs (Total {}):".format(len(outside)))
for ip in outside:
    print(f"  - {ip}")
_____________________________________

📊 IP Subnet Distribution:
🔹 8.8.0.0/22: 6 IP
🔹 9.9.0.0/22: 2 IP

❌ Unclassified IPs (Total 2):
  - 10.10.0.9
  - 10.10.0.10
