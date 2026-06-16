# Ebony & Ivory: Dual-Protocol Scanner (Bash Edition)
<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/c3738267-a3c4-42cf-9d9b-7fd739634cf4" />



A lightweight Bash adaptation of the Ebony & Ivory network enumeration script. It relies entirely on native Bash terminal features (`/dev/tcp` and `/dev/udp`) and system utilities to map networks without requiring third-party libraries or root privileges.

## Features

- **Ping Verification & Sweep:** Automatically probes single hosts or systematically maps sequential IP ranges (`.1` to `.254`) using ICMP echo requests before initializing a scan.
- **Zero Dependencies:** Operates natively without requiring Python, Nmap, or Netcat. It uses built-in shell device redirection.
- **Ivory (TCP Scan):** Establishes standard TCP handshake connection attempts safely wrapped in a strict timeout ceiling.
- **Ebony (UDP Scan):** Pipes empty system pulses to remote targets to verify protocol socket availability.
- **No Sudo Required:** Can be safely executed from standard unprivileged user terminal prompts.

## Setup

1. Save the code into a local script file named `ebony_ivory.sh`.
2. Apply standard terminal executable flag permissions before running:
```bash
chmod +x ebony_ivory.sh
```

## Usage

### Scan a Single Host (Verifies Host is Alive First)
```bash
./ebony_ivory.sh -t 192.168.1.50
```

### Sweep a Whole Local Network (Uses 3-Octet Base Range)
```bash
./ebony_ivory.sh -t 192.168.1
```

### Run Ivory Only (TCP)
```bash
./ebony_ivory.sh -t 192.168.1.50 -m ivory
```

### Run Ebony Only (UDP)
```bash
./ebony_ivory.sh -t 192.168.1.50 -m ebony
```

## Protocol Limitations

Because this uses basic shell-level socket interaction instead of raw packet injection:
- **TCP Scans** perform a Full-Open handshake rather than a Stealth SYN scan. This will register in target server application logs.
- **UDP Scans** cannot natively parse complex incoming raw ICMP destination-unreachable frames. All unresponsive UDP ports return as `OPEN | FILTERED`.

