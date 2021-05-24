#!/bin/sh

IFACE=$(ip addr ls | grep tun | head -n 1 | awk '{print $2}' | cut -f1 -d ':')
# show vpn active connections
# nmcli c show --active | grep vpn | awk '{print $3}'
if [ "${IFACE:0:3}" = "tun" ]; then
    echo "$(ip addr ls label tun0 | grep inet | awk '{print $2}' | cut -f2 -d ':')"
else
    echo "VPN DISCONNECTED"
fi
