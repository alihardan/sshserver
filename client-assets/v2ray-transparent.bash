#!/usr/bin/env bash

# Thanks to: https://www.v2ray.com/en/configuration/protocols/dokodemo.html

# Create new chain
iptables -t nat -N V2RAY
iptables -t mangle -N V2RAY
iptables -t mangle -N V2RAY_MARK

# Ignore your server proccess
# It's very IMPORTANT, just be careful.
iptables -t nat -A OUTPUT -m owner --uid-owner "tor" -j RETURN
# iptables -t mangle -A OUTPUT -m owner --uid-owner "tor" -j RETURN # Not worked
# iptables -t mangle -A POSTROUTING -m owner --uid-owner "tor" -j RETURN # Not worked

# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN

# Anything else should be redirected to Dokodemo-door's local port
iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 9997

# Add any UDP rules
ip route add local default dev lo table 100
ip rule add fwmark 1 lookup 100
iptables -t mangle -A V2RAY -p udp -j TPROXY --on-port 9997 --tproxy-mark 0x01/0x01
iptables -t mangle -A V2RAY_MARK -p udp -j MARK --set-mark 1

# Apply the rules
iptables -t nat -A OUTPUT -p tcp -j V2RAY
# iptables -t nat -A PREROUTING -p tcp -j V2RAY # Is it needed? added by me
iptables -t mangle -A PREROUTING -j V2RAY
iptables -t mangle -A OUTPUT -j V2RAY_MARK