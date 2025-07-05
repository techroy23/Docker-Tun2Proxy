# Docker-Tun2Proxy

A minimal Alpine-based Docker image that installs the latest `tun2proxy` binary and transparently redirects all outgoing DNS queries to your preferred resolver via `iptables`. Ideal for secure tunneling, private DNS setups, or embedding tun2proxy into containerized environments.

---

## Table of Contents

- [Features](#features)  
- [Prerequisites](#prerequisites)  
- [Quick Start](#quick-start)  

---

## Features

- Alpine Linux base for minimal footprint. 
- Auto-fetches and installs the latest `tun2proxy` release from GitHub  
- Intercepts DNS requests to common public resolvers (1.1.1.1, 8.8.8.8, etc.)  
- Redirects intercepted DNS to your specified `TARGETDNS` via `iptables` DNAT  
- Launches `tun2proxy` in the foreground as PID 1  

---

## Prerequisites

- Docker
- Host must permit:
  - `--cap-add=NET_ADMIN` (or `--privileged`)  
  - `--device /dev/net/tun`  

---

## Quick Start

```bash
docker run -d \
  --name customtun2proxy \                             # Name your container for easy reference
  --cap-add=NET_ADMIN \                                # Adds administrative networking capabilities (needed for TUN device)
  -e TARGETDNS=1.1.1.1 \                             # Set the target DNS server environment variable
  -v /dev/net/tun:/dev/net/tun \                       # Mount the host TUN device into the container
  ghcr.io/techroy23/docker-tun2proxy:latest \          # Use the built Docker image
  --proxy socks5://username:password@x.x.x.x:xxxxx \   # Configure the upstream SOCKS5 proxy
  --dns over-tcp \                                     # Force DNS resolution to use TCP (reduces potential for DNS leaks)
  --dns-addr 1.1.1.1                                 # Explicitly define DNS server to use

# Tip: For better privacy and reliability, consider setting up your **own DNS resolver** (e.g., Unbound or CoreDNS)
# and point `TARGETDNS` and `--dns-addr` to that instead of using public resolvers.
# This avoids data leakage and gives you more control.
```

---

## Options

| Option                          | Description                                                                                                                                          |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-p, --proxy <URL>`             | Proxy URL in the form `proto://[username[:password]@]host:port` (supports `socks4`, `socks5`, `http`). Percent-encode username/password. <br>_Example:_ `socks5://myname:pass%40word@127.0.0.1:1080` |
| `-t, --tun <name>`              | Name of the TUN interface (e.g., `tun0`, `utun4`). If omitted, a random name is generated.                                                           |
| `--tun-fd <fd>`                 | File descriptor for the TUN interface.                                                                                                               |
| `--close-fd-on-drop <true/false>` | Close the received raw file descriptor on drop. Defaults to `false`.                                                                                |
| `--unshare`                     | Create the TUN interface in a new unprivileged namespace while retaining proxy connectivity to the global namespace.                                  |
| `--unshare-pidfile <file>`      | Path to write the `unshare` process PID file.                                                                                                        |
| `-6, --ipv6-enabled`            | Enable IPv6 support.                                                                                                                                 |
| `-s, --setup`                   | Perform routing and system configuration (requires root-like privileges).                                                                            |
| `-d, --dns <strategy>`          | DNS handling strategy. <br>_Options:_ `direct` (default), `virtual`, `over-tcp`.                                                                      |
| `--dns-addr <IP>`               | DNS resolver address (default: `8.8.8.8`).                                                                                                           |
| `--virtual-dns-pool <CIDR>`     | CIDR pool for virtual DNS (default: `198.18.0.0/15`).                                                                                                 |
| `-b, --bypass <IP/CIDR>`        | IPs or networks to bypass the tunnel. Can be repeated. <br>_Example:_ `--bypass 3.4.5.0/24 --bypass 5.6.7.8`                                            |
| `--tcp-timeout <seconds>`       | TCP connection timeout in seconds (default: `600`).                                                                                                   |
| `--udp-timeout <seconds>`       | UDP session timeout in seconds (default: `10`).                                                                                                       |
| `-v, --verbosity <level>`       | Logging verbosity. <br>_Options:_ `off`, `error`, `warn`, `info` (default), `debug`, `trace`.                                                         |
| `--daemonize`                   | Run as a background service (daemon or Windows service).                                                                                              |
| `--exit-on-fatal-error`         | Exit immediately on fatal errors (useful in service mode).                                                                                            |
| `--max-sessions <number>`       | Maximum concurrent sessions (default: `200`).                                                                                                         |
| `--udpgw-server <IP:PORT>`      | UDP gateway server address (for forwarding UDP over TCP).                                                                                             |
| `--udpgw-connections <number>`  | Max connections for the UDP gateway (default: `5`).                                                                                                   |
| `--udpgw-keepalive <seconds>`   | Keepalive interval for the UDP gateway (default: `30`).                                                                                               |
| `-h, --help`                    | Show help message.                                                                                                                                   |
| `-V, --version`                 | Print version information.                                                                                                                            |
