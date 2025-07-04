#!/bin/bash

# Usage:
# ./main.sh <network> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]

NETWORK="$1"
MODE="$2"
DECOY_LIST="$3"

if [[ -z "$NETWORK" ]]; then
    echo "Usage: $0 <network> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]"
    exit 1
fi

DATE="$(date -I)"
NETWORK_NAME="${NETWORK%%/*}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"
RESULTS_DIR="${SCRIPT_DIR}/../results"
FILENAME_PREFIX="${RESULTS_DIR}/${NETWORK_NAME}_${DATE}"

echo "[*] Step 1 - Running network discovery..."
"${SCRIPT_DIR}/network-scan.sh" "$NETWORK"

LIVE_HOSTS_FILE="${FILENAME_PREFIX}_live_hosts.txt"

if [[ ! -s "$LIVE_HOSTS_FILE" ]]; then
    echo "[!] No live hosts found. Exiting."
    exit 0
fi

echo "[*] Step 2 - Running port scan..."
"${SCRIPT_DIR}/port-scan.sh" "$LIVE_HOSTS_FILE" "$MODE" "$DECOY_LIST"

OPEN_PORTS_FILE="${FILENAME_PREFIX}_open_ports.txt"

if [[ ! -s "$OPEN_PORTS_FILE" ]]; then
    echo "[!] No open ports found. Exiting."
    exit 0
fi

echo "[*] Step 3 - Running version scan..."
"${SCRIPT_DIR}/version-scan.sh" "$OPEN_PORTS_FILE" "$MODE" "$DECOY_LIST"

echo "[*] All scanning steps completed."