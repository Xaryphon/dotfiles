#!/bin/sh

IP_MATCH_REGEX='^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.'\
'(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.'\
'(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.'\
'(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$'

cdf="$XDG_RUNTIME_DIR/i3blocks_public_ip_cache"
ccf="$XDG_RUNTIME_DIR/i3blocks_public_ip_cache2"
ccn="$(ip route show)"
crt=60
if [ -f "$ccf" ]; then
    ccw=$(( $(date +%s) - $(stat -c %Y "$ccf") ))
    if [ $ccw -lt $crt ]; then
        cco="$(cat "$ccf")"
        if [ "$ccn" = "$cco" ]; then
            if [ -f "$cdf" ]; then
                cat "$cdf"
                exit
            fi
        fi
    fi
fi
printf "%s" "$ccn" > "$ccf"

vpn_active=0
if pgrep openvpn || ! wg > /dev/null 2> /dev/null; then
    vpn_active=1
fi

if [ $vpn_active -eq 0 ]; then
    pd=" "
else
    pd=" "
fi

# Check if we're connected to a network
gateway_ip="$(ip route | grep default | grep -Eo "via [^ ]+" | cut -d ' ' -f 2)"
if [ "$gateway_ip" ]; then
    # Check if the gateway is reachable
    #ping -q -w 1 -c 1 $gateway_ip &> /dev/null;
    #if [[ $? -eq 0 ]]; then
        # Check if we have internet access and get public ip
        public_ip="$(curl https://ipecho.net/plain)"
        got_public_ip=$?
        if [ $got_public_ip -eq 0 ]; then
            if printf "%s" "$public_ip" | grep -Eq "$IP_MATCH_REGEX"; then
                pd="${pd}$public_ip"
            else
                pd="${pd}502 Bad Gateway"
            fi
        else
            pd="${pd}$(ip route | grep default | grep -Eo "src [^ ]+" | cut -d ' ' -f 2)"
        fi
    #else
    #    pd="${pd}127.0.0.1"
    #fi
else
    pd="${pd}127.0.0.1"
fi

if [ $vpn_active -eq 0 ]; then
    pdc="#FF0000"
else
    pdc="#00FF00"
fi

printf "%s\n\n%s" "$pd" "$pdc" | tee "$cdf"
