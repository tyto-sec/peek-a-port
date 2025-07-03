#!/bin/bash

# Usage:
# ./host-enum.sh <hosts_file>

HOSTS_FILE="$1"
HOSTS_FILE_BASENAME="$(basename "$HOSTS_FILE")"
HOSTS_FILE_NAME="${HOSTS_FILE_BASENAME%%_*}"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME_PREFIX="${SCRIPT_DIR}/../results/${HOSTS_FILE_NAME}_${DATE}"

if [[ ! -f "$HOSTS_FILE" ]]; then
    echo "Error: Invalid hosts file '$HOSTS_FILE'."
    echo "Usage: $0 <hosts_file>"
    exit 1
fi

while read -r HOST; do
    if [[ -n "$HOST" ]]; then
        echo "[*] Enumerating host: $HOST"
        enum4linux -a "$HOST" > "${FILENAME_PREFIX}_${HOST}_enum4linux.log"
    fi
done < "$HOSTS_FILE"