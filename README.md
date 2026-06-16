# Ebony & Ivory: Dual-Protocol Scanner

A custom Python script utilizing the Scapy library to conduct low-level network enumeration via TCP and UDP. Inspired by Dante's signature pistols, **Ivory** handles rapid TCP SYN scans, while **Ebony** investigates connectionless UDP ports using ICMP error behavior. Based off Devil May Cry Ebony & Ivory guns. 

## Features

- **Ivory (TCP SYN Scan):** Conducts stealthy "half-open" scans by analyzing TCP response flags without establishing full connections.
- **Ebony (UDP Scan):** Identifies active UDP services by handling connectionless timeouts and catching ICMP Port Unreachable packets.
- **Selective Modes:** Run either protocol independently or deploy both simultaneously for a full enumeration sweep.

## Prerequisites

The script utilizes raw network sockets to craft custom packet headers. Because of this, it requires root/administrator privileges and the Scapy library.

Install Scapy via pip:
```bash
sudo apt install python3-venc
python3 -m venv my-env
source my-env/bin/activate
pip install scapy
```

## Usage

You must execute this script with `sudo` to grant Scapy raw packet injection capabilities.

### Run Full Combo (Both Protocols)
```bash
sudo python3 ebony_ivory.py -t <TARGET_IP>
```

### Run Ivory Only (TCP)
```bash
sudo python3 ebony_ivory.py -t <TARGET_IP> --mode ivory
```

### Run Ebony Only (UDP)
```bash
sudo python3 ebony_ivory.py -t <TARGET_IP> --mode ebony
```

## Default Scanned Ports

- **TCP:** 21 (FTP), 22 (SSH), 23 (Telnet), 25 (SMTP), 53 (DNS), 80 (HTTP), 110 (POP3), 139 (NetBIOS), 143 (IMAP), 443 (HTTPS), 445 (SMB), 3306 (MySQL), 3389 (RDP), 5985 (winrm).
- **UDP:** 53 (DNS), 67/68 (DHCP), 69 (TFTP), 123 (NTP), 137/138 (NetBIOS), 161 (SNMP), 514 (Syslog).

