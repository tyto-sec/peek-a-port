#!/bin/bash

# Usage:
# ./network-scan.sh <network>

NETWORK=$1
NETWORK_NAME=${NETWORK%%/*}
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME_PREFIX="${SCRIPT_DIR}/../results/${NETWORK_NAME}_${DATE}"

nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $NETWORK -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml"

xmlstarlet sel -t -m "//host[status/@state='up']" -v "address[@addrtype='ipv4']/@addr" -n "${FILENAME_PREFIX}_nmap_host_discovery.xml" > "${FILENAME_PREFIX}_live_hosts.txt"
