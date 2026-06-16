#!/bin/bash

# Dante's Arsenal Config
DEFAULT_TCP_PORTS=(21 22 23 25 53 80 88 110 139 143 443 445 389 636 3306 3389 5985)
DEFAULT_UDP_PORTS=(53 67 68 69 123 137 138 161 514)

# Default configuration settings
TARGET=""
MODE="both"
TIMEOUT=1

print_banner() {
    echo "=================================================="
    echo "    EBONY & IVORY: Dual-Protocol Scanner (Bash)   "
    echo "          \"It's showtime!\" - Dante            "
    echo "=================================================="
    echo ""
}

print_usage() {
    echo "Usage: $0 -t <target_ip> [--mode <ivory|ebony|both>]"
    echo "  -t, --target    Target IP address"
    echo "  -m, --mode      ivory (TCP), ebony (UDP), or both (Default)"
    exit 1
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--target) TARGET="$2"; shift ;;
        -m|--mode) MODE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; print_usage ;;
    esac
    shift
done

# Enforce target parameter requirement
if [ -z "$TARGET" ]; then
    print_banner
    print_usage
fi

ivory_tcp_scan() {
    echo "[Ivory] Firing TCP shots at $TARGET..."
    for port in "${DEFAULT_TCP_PORTS[@]}"; do
        # Use timeout to prevent hanging on closed/filtered ports
        # Redirect descriptor 3 to the built-in Bash TCP virtual device
        if timeout $TIMEOUT bash -c "exec 3<>/dev/tcp/$TARGET/$port" 2>/dev/null; then
            echo "   [+] TCP Port $port OPEN"
        fi
    done
}

ebony_udp_scan() {
    echo -e "\n[Ebony] Firing UDP probe shots at $TARGET..."
    for port in "${DEFAULT_UDP_PORTS[@]}"; do
        # UDP is connectionless; we write a dummy payload to check if the port accepts it
        if timeout $TIMEOUT bash -c "exec 3<>/dev/udp/$TARGET/$port && echo -n >&3" 2>/dev/null; then
            echo "   [+] UDP Port $port OPEN | FILTERED"
        fi
    done
}

# Execution flow control
print_banner

if [ "$MODE" = "ivory" ] || [ "$MODE" = "both" ]; then
    ivory_tcp_scan
fi

if [ "$MODE" = "ebony" ] || [ "$MODE" = "both" ]; then
    ebony_udp_scan
fi

echo -e "\n[*] Jackpot! Scan sequence completed successfully."
