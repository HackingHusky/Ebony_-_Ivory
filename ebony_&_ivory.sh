#!/bin/bash

# Dante's Arsenal Config
DEFAULT_TCP_PORTS=(21 22 23 25 53 80 88 110 139 143 443 445 389 636 1433 3306 3389 5985)
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
    echo "Usage: $0 -t <target_ip_or_network> [--mode <ivory|ebony|both>]"
    echo "  -t, --target    Target IP address (e.g., 192.168.1.50) or base range (e.g., 192.168.1)"
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

print_banner

# Determine if the target is a single IP or a 3-octet subnet range
TARGET_HOSTS=()
if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[*] Commencing Ping Sweep on network range: ${TARGET}.1-254"
    for i in {1..254}; do
        # Send 1 ICMP request packet with a 1-second timeout
        if ping -c 1 -W 1 "${TARGET}.${i}" >/dev/null 2>&1; then
            echo "   [+] Host Detected: ${TARGET}.${i}"
            TARGET_HOSTS+=("${TARGET}.${i}")
        fi
    done
    if [ ${#TARGET_HOSTS[@]} -eq 0 ]; then
        echo "[-] No live hosts found during the ping sweep. Exiting."
        exit 0
    fi
    echo -e "\n[*] Proceeding to enumerate ${#TARGET_HOSTS[@]} live target(s)..."
else
    # Verify the individual target host answers to a ping check first
    echo "[*] Verifying host availability via ping: $TARGET"
    if ping -c 1 -W 1 "$TARGET" >/dev/null 2>&1; then
        echo "   [+] Host is up!"
        TARGET_HOSTS+=("$TARGET")
    else
        echo "[-] Target host did not respond to ping. Skipping execution."
        exit 0
    fi
fi

ivory_tcp_scan() {
    local current_host=$1
    echo "[Ivory] Firing TCP shots at $current_host..."
    for port in "${DEFAULT_TCP_PORTS[@]}"; do
        # Use timeout to prevent hanging on closed/filtered ports
        # Redirect descriptor 3 to the built-in Bash TCP virtual device
        if timeout $TIMEOUT bash -c "exec 3<>/dev/tcp/$current_host/$port" 2>/dev/null; then
            echo "   [+] TCP Port $port OPEN"
        fi
    done
}

ebony_udp_scan() {
    local current_host=$1
    echo -e "\n[Ebony] Firing UDP probe shots at $current_host..."
    for port in "${DEFAULT_UDP_PORTS[@]}"; do
        # UDP is connectionless; we write a dummy payload to check if the port accepts it
        if timeout $TIMEOUT bash -c "exec 3<>/dev/udp/$current_host/$port && echo -n >&3" 2>/dev/null; then
            echo "   [+] UDP Port $port OPEN | FILTERED"
        fi
    done
}

# Run the weapon rotations across all confirmed live targets
for host in "${TARGET_HOSTS[@]}"; do
    echo -e "\n--------------------------------------------"
    echo "Target Focus: $host"
    echo "--------------------------------------------"

    if [ "$MODE" = "ivory" ] || [ "$MODE" = "both" ]; then
        ivory_tcp_scan "$host"
    fi

    if [ "$MODE" = "ebony" ] || [ "$MODE" = "both" ]; then
        ebony_udp_scan "$host"
    fi
done

echo -e "\n[*] Jackpot! Scan sequence completed successfully."
