#!/bin/bash

# Usage:
# ./version-scan.sh <open_ports_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]

OPEN_PORTS_FILE="$1"
MODE="$2"
DECOY_LIST="$3"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/../results"
OPEN_PORTS_BASENAME="$(basename "$OPEN_PORTS_FILE")"
OPEN_PORTS_NAME="${OPEN_PORTS_BASENAME%%_*}"
FILENAME_PREFIX="${RESULTS_DIR}/${OPEN_PORTS_NAME}_${DATE}"

if [[ ! -f "$OPEN_PORTS_FILE" ]]; then
    echo "Error: Invalid open ports file '$OPEN_PORTS_FILE'."
    echo "Usage: $0 <open_ports_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]"
    exit 1
fi

NMAP_OPTS="-sV -T4 -Pn -n -O --script banner"

case "$MODE" in
    stealth)
        echo "[*] Ninja mode..."
        NMAP_OPTS="-sS -T2 -g 53 -Pn -n --script banner"
        ;;
    stealth_slow)
        echo "[*] Patience young padawan, this can take time..."
        NMAP_OPTS="-sS -T1 -g 53 -Pn -n --script banner"
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

declare -A TARGETS

while read -r line; do
    HOST="${line%%:*}"
    PORT="${line##*:}"

    if [[ -n "$HOST" && -n "$PORT" ]]; then
        TARGETS["$HOST"]="${TARGETS[$HOST]},$PORT"
    fi
done < "$OPEN_PORTS_FILE"

for HOST in "${!TARGETS[@]}"; do
    PORTS="${TARGETS[$HOST]}"
    PORTS="${PORTS#,}"

    echo "[*] Scanning $HOST ports: $PORTS"

    nmap $NMAP_OPTS -p "$PORTS" \
        -oX "${FILENAME_PREFIX}_${HOST}_service_scan.xml" \
        "$HOST"

    xsltproc "${FILENAME_PREFIX}_${HOST}_service_scan.xml" -o "${FILENAME_PREFIX}_${HOST}_version_scan.html"
done

OUTPUT_FILE="${FILENAME_PREFIX}_services.txt"
> "$OUTPUT_FILE"

for xmlfile in "${FILENAME_PREFIX}"_*_service_scan.xml; do
    xmlstarlet sel -t \
        -m "//host" \
        -m "ports/port[state/@state='open']" \
            -v "concat(
                ../../address[@addrtype='ipv4']/@addr, ':',
                @portid, ':',
                service/@name, ':',
                string(service/@product), ':',
                string(service/@version), ':',
                string(service/@extrainfo), ':',
                string(service/@ostype), ':',
                string(script[@id='banner']/@output)
            )" -n \
        "$xmlfile" >> "$OUTPUT_FILE"
done

echo "[*] Services saved to: $OUTPUT_FILE"
