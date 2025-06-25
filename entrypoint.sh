#!/bin/sh
set -e 

# List of public DNS servers we want to intercept
HARD_CODED_DNS="1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4"

# Use TARGETDNS env var if provided; otherwise fall back to this IP
TARGET_DNS="${TARGETDNS:-76.76.2.3}"

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
