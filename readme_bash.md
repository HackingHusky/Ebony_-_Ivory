# Ebony & Ivory: Dual-Protocol Scanner (Bash Edition)
<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/28867172-64bb-45dd-a537-4de6f99ca242" />


A lightweight Bash adaptation of the Ebony & Ivory network enumeration script. It relies entirely on native Bash terminal features (`/dev/tcp` and `/dev/udp`) to scan ports without requiring third-party libraries, Python environments, or root privileges.

## Features

- **Zero Dependencies:** Operates without Python, Nmap, or Netcat. It uses built-in shell device redirection.
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

### Run Full Combo (Both Protocols)
```bash
./ebony_ivory.sh -t <TARGET_IP>
```

### Run Ivory Only (TCP)
```bash
./ebony_ivory.sh -t <TARGET_IP> -m ivory
```

### Run Ebony Only (UDP)
```bash
./ebony_ivory.sh -t <TARGET_IP> -m ebony
```

## Protocol Limitations

Because this uses basic shell-level socket interaction instead of raw packet injection:
- **TCP Scans** perform a Full-Open handshake rather than a Stealth SYN scan. This will register in target server application logs.
- **UDP Scans** cannot natively parse complex incoming raw ICMP destination-unreachable frames. All unresponsive UDP ports return as `OPEN | FILTERED`.
