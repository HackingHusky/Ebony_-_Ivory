# Ebony & Ivory: Dual-Protocol Scanner
<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/7bdc8d0c-581e-459c-baad-97c7155260e5" />



A custom Python script utilizing the Scapy library to conduct low-level network enumeration via TCP and UDP. Inspired by Dante's signature pistols, **Ivory** handles rapid TCP SYN scans, while **Ebony** investigates connectionless UDP ports using ICMP error behavior. Based off Devil May Cry Ebony & Ivory guns.

## Features

- **Ping Verification & Sweep:** Verifies single host availability or sweeps an entire CIDR network block using fast ICMP echoes before running port scans.
- **Ivory (TCP SYN Scan):** Conducts stealthy "half-open" scans by analyzing TCP response flags without establishing full connections.
- **Ebony (UDP Scan):** Identifies active UDP services by handling connectionless timeouts and catching ICMP Port Unreachable packets.
- **Selective Modes:** Run either protocol independently or deploy both simultaneously for a full enumeration sweep.

## Prerequisites

The script utilizes raw network sockets to craft custom packet headers. Because of this, it requires root/administrator privileges and the Scapy library.

Install Scapy via pip:
```bash
sudo apt install python3-venv
python3 -m venv my-env
source my-env/bin/activate
pip install scapy
```

## Usage

You must execute this script with `sudo` to grant Scapy raw packet injection capabilities.

### Scan a Single Host (Verifies Host is Alive First)
```bash
sudo python3 ebony_ivory.py -t 192.168.1.50
```

### Sweep a Whole Network Subnet (Discovers Live Hosts First)
```bash
sudo python3 ebony_ivory.py -t 192.168.1.0/24
```

### Run Ivory Only (TCP)
```bash
sudo python3 ebony_ivory.py -t 192.168.1.50 --mode ivory
```

### Run Ebony Only (UDP)
```bash
sudo python3 ebony_ivory.py -t 192.168.1.50 --mode ebony
```

## Default Scanned Ports

- **TCP:** 21 (FTP), 22 (SSH), 23 (Telnet), 25 (SMTP), 53 (DNS), 80 (HTTP), 88 (Kerberos), 110 (POP3), 139 (NetBIOS), 143 (IMAP), 443 (HTTPS), 445 (SMB), 389 (LDAP), 636 (LDAPS), 3306 (MySQL), 3389 (RDP), 5985 (winrm).
- **UDP:** 53 (DNS), 67/68 (DHCP), 69 (TFTP), 123 (NTP), 137/138 (NetBIOS), 161 (SNMP), 514 (Syslog).


