#!/bin/bash

# Usage:
# ./service-enum.sh <services_file>

SERVICES_FILE="$1"

if [[ ! -f "$SERVICES_FILE" ]]; then
    echo "Error: File not found: $SERVICES_FILE"
    exit 1
fi

while IFS=: read -r HOST PORT PROTOCOL PRODUCT VERSION _; do

    # Ignore empty lines
    if [[ -z "$HOST" || -z "$PORT" || -z "$PROTOCOL" ]]; then
        continue
    fi

    echo "[*] Processing $HOST:$PORT ($PROTOCOL) - $PRODUCT $VERSION"

    # Dispatch to different scripts
    case "$PROTOCOL" in

        ssh)
            ./enum_ssh.sh "$HOST" "$PORT" "$PRODUCT" "$VERSION"
            ;;

        http)
            ./enum_http.sh "$HOST" "$PORT" "$PRODUCT" "$VERSION"
            ;;

        domain)
            ./enum_dns.sh "$HOST" "$PORT" "$PRODUCT" "$VERSION"
            ;;

        *)
            echo "[!] No enum script defined for protocol: $PROTOCOL"
            ;;
    esac

done < "$SERVICES_FILE"
