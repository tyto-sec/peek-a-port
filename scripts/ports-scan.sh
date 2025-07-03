#!/bin/bash

# Usage:
# ./scan.sh <hosts_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]

HOSTS_FILE="$1"
HOSTS_FILE_BASENAME="$(basename "$HOSTS_FILE")"
HOSTS_FILE_NAME="${HOSTS_FILE_BASENAME%%_*}"
MODE="$2"
DECOY_LIST="$3"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME_PREFIX="${SCRIPT_DIR}/../results/${HOSTS_FILE_NAME}_${DATE}"
FILENAME="${FILENAME_PREFIX}_nmap_port_scan.xml"

if [[ ! -f "$HOSTS_FILE" ]]; then
  echo "Error: Invalid hosts file '$HOSTS_FILE'."
  echo "Usage: $0 <hosts_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]"
  exit 1
fi

NMAP_OPTS="-sS -sU --top-ports 50 -T5 -Pn -n -p-"

case "$MODE" in
  stealth)
    echo "[*] Ninja mode..."
    NMAP_OPTS="-sS -sU --top-ports 50 -T2 -g 53 -Pn -n -p-"
    ;;
  stealth_slow)
    echo "[*] Patience young padawan, this can take time..."
    NMAP_OPTS="-sS -sU --top-ports 50 -T1 -g 53 -Pn -n -p-"
    ;;
  *)
    if [[ -n "$MODE" ]]; then
      echo "[*] Invalid mode: $MODE"
      echo "Use: stealth or stealth_slow"
      exit 1
    fi
    echo "[*] This will be as quick as possible..."
    ;;
esac

if [[ -n "$DECOY_LIST" ]]; then
  echo "[*] Using decoy(s): $DECOY_LIST"
  NMAP_OPTS="$NMAP_OPTS -D $DECOY_LIST"
fi

nmap $NMAP_OPTS -oX "${FILENAME_PREFIX}_nmap_port_discovery.xml" -iL "$HOSTS_FILE"

xmlstarlet sel -t \
  -m "//host[status/@state='up']" \
    -m "ports/port[state/@state='open']" \
      -v "concat(../../address[@addrtype='ipv4']/@addr, ':', @portid)" \
      -n \
  "${FILENAME_PREFIX}_nmap_port_discovery.xml" \
  > "${FILENAME_PREFIX}_open_ports.txt"