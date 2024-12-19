import geoip2.database
from ipwhois import IPWhois
import time

t1 = time.time()
database_path = 'GeoLite2-City.mmdb'
file = 'ip.txt'
out = 'out.txt'

with geoip2.database.Reader(database_path) as reader:
    with open(file, 'r') as f, open(out, 'w') as out:
        out.write(f"IP|geo_country|geo_city|geo_latitude|geo_longitude|geo_network|whois_country|whois_city|whois_address|whois_asn\n")
        for line in f:
            ip = line.strip()
            
            #geoip
            response = reader.city(ip)
            #country_code = response.country.iso_code
            g_country = response.country.name
            g_city = response.city.name
            g_latitude = response.location.latitude
            g_longitude = response.location.longitude
            g_network = response.traits.network
            #print (f'{ip} {g_country} {g_city} {g_latitude} {g_longitude} {g_network}')

            #ipwhois 
            data = IPWhois(ip)
            data = data.lookup_whois()
            w_country = data['nets'][0]['country']
            w_city = data['nets'][0]['city']
            w_address = data['nets'][0]['address']
            w_asn = data['asn']
            #print (f'{ip} {w_country} {w_city} {w_address}')
            
            
            result = f"{ip}|{g_country}|{g_city}|{g_latitude}|{g_longitude}|{g_network}|{w_city}|{w_address}|{w_asn}\n"
            out.write(result)
            sleep(2)
            #print(f"{ip}|{g_country}|{g_city}|{g_latitude}|{g_longitude}|{g_network}|{w_country}|{w_city}|{w_address}|{w_asn}\n")
t2 = time.time()
print(f'It was spent about {round(t2-t1, 5)} seconds.')
