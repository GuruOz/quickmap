# quickmap
A script that uses nmap to make port scanning of all 65,535 ports extremely quick.

Place the script into one of your path folder, like /usr/bin/quickmap

Functionality:
1. Scans all ports from 0-65,535
2. After finding all open ports, it will run a detailed scan using default nmap scripts to fingerprint the services
3. Saves the output in the current working directory

Usage: quickmap <IP address\>
Example: quickmap 10.10.11.245

<img width="767" alt="image" src="https://github.com/GuruOz/quickmap/assets/46161797/5a707835-34b1-4eb9-87e2-d98e63869407">

