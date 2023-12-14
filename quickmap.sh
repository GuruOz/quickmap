#!/bin/bash
# This script takes an IP address as an argument and runs two nmap commands on it
# The first command scans all ports and saves the open ports to a variable
# The second command scans the open ports and saves the output to a file

# Check if an IP address is provided
if [ -z "$1" ]; then
  echo "Please provide an IP address as an argument."
  exit 1
fi

# Run the first nmap command and extract the open ports
echo "Running nmap -p- -T4 -Pn -vvv $1"
ports=$(nmap -p- -T4 -Pn -vvv $1 -oN nmap | grep "syn-ack" | cut -d "/" -f 1 | tr "\n" "," | sed "s/,$//")

# Check if any ports are found
if [ -z "$ports" ]; then
  echo "No open ports found."
  exit 2
fi

directory=$(pwd)

# Run the second nmap command and save the output to a file
echo "Running nmap -p $ports -sCV $1 -o $directory/nmap"
nmap -p $ports -sV $1 -o nmap
echo "Done. The output is saved in nmap file."
