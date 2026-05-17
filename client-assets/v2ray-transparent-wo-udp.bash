#!/usr/bin/env bash

# Thanks to: https://www.v2ray.com/en/configuration/protocols/dokodemo.html


setup_iptables() {
    case "$1" in
        proxy)
            # Create new chain
            iptables -t nat -N V2RAY
            
            # Ignore your server proccess
            # It's very IMPORTANT, just be careful.
            iptables -t nat -A OUTPUT -m owner --uid-owner "tor" -j RETURN
            iptables -t nat -A OUTPUT -m owner --uid-owner "dnscrypt-proxy" -j RETURN
            
            # Ignore LANs and any other addresses you'd like to bypass the proxy
            # See Wikipedia and RFC5735 for full list of reserved networks.
            iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
            iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
            iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
            iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
            iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
            iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
            iptables -t nat -A V2RAY -d 192.168.1.0/16 -j RETURN
            iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
            iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN


            # Anything else should be redirected to Dokodemo-door's local port
            iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 9997
            
            # Apply the rules
            iptables -t nat -A OUTPUT -p tcp -j V2RAY
            # iptables -t nat -A PREROUTING -p tcp -j V2RAY # Is it needed? added by me
        ;;

        # restore default
        default)
            printf "%s\\n" "Restore default iptables"

            # flush iptables rules
            iptables -F
            iptables -X
            iptables -t nat -F
            iptables -t nat -X
            iptables -P INPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -P OUTPUT ACCEPT
            systemctl restart iptables

        ;;
    esac

}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -s | --start)
            setup_iptables proxy
            ;;
        -c | --clear)
            setup_iptables default
            ;;
        -- | -* | *)
            printf "%s\\n" "${prog_name}: Invalid option '$1'"
            printf "%s\\n" "Try '${prog_name} --help' for more information."
            exit 1
            ;;
    esac
    exit 0
done
