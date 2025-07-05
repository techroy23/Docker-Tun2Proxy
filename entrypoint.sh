#!/bin/sh
set -e 

# List of public DNS servers we want to intercept
HARD_CODED_DNS="1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 8.20.247.20 8.26.56.26 9.9.9.9 64.6.64.6 64.6.65.6 76.76.19.19 76.223.122.150 77.88.8.1 77.88.8.2 77.88.8.3 77.88.8.7 77.88.8.8 77.88.8.88 84.200.69.80 84.200.70.40 94.140.14.14 94.140.14.15 94.140.14.140 94.140.14.141 94.140.15.15 94.140.15.16 149.112.112.112 185.228.168.9 185.228.168.10 185.228.168.168 185.228.169.9 185.228.169.11 185.228.169.168 208.67.220.220 208.67.222.222"

# Use TARGETDNS env var if provided; otherwise fall back to this IP
TARGET_DNS="${TARGETDNS:-1.1.1.1}"

# Clear out any existing NAT OUTPUT rules so we start fresh
iptables -t nat -F OUTPUT

# Loop through each DNS server in our list...
for d in $HARD_CODED_DNS; do
  # ...and add a rule to catch UDP-based DNS queries
  iptables -t nat -A OUTPUT -p udp --dport 53 -d "$d" -j DNAT --to-destination "$TARGET_DNS"
  # ...and another to catch TCP-based DNS queries
  iptables -t nat -A OUTPUT -p tcp --dport 53 -d "$d" -j DNAT --to-destination "$TARGET_DNS"
done

# Show the installed NAT OUTPUT rules with line numbers
echo " "
echo "Installed DNS redirection rules:"
echo " "
iptables -t nat -L OUTPUT -n --line-numbers

echo " "
echo "Launching: /app/tun2proxy-bin --setup $*"
echo " "
cd /app
/app/tun2proxy-bin --setup $@