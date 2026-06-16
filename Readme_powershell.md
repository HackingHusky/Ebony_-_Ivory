# Ebony & Ivory: Dual-Protocol Scanner (PowerShell Edition)
<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/c1b2edb6-cadd-4eaf-9abb-a730008441fc" />


A lightweight PowerShell adaptation of the Ebony & Ivory network enumeration toolkit. It leverages native `.NET` framework network namespaces (`System.Net.Sockets`) to systematically discover hosts and scan target environments without external tools or elevated administrative privileges.

## Features

- **Ping Verification & Sweep:** Automatically uses the `.NET` Ping class to establish baseline single-host status or maps sequential target lists (`.1` to `.254`) across 3-octet ranges.
- **Zero Module Dependencies:** Runs natively out of standard default shell runtimes without importing third-party modules.
- **Ivory (TCP Scan):** Performs parallel TCP handshakes with strict millisecond asynchronous timeout limits.
- **Ebony (UDP Scan):** Pipes quick validation byte streams to map open listening socket structures.
- **No Admin Required:** Runs efficiently inside normal, unprivileged PowerShell terminal prompts.

## Setup & Execution Policy

Before executing external scripts, your local terminal session may require execution clearance:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
New-NetFirewallRule -DisplayName "Allow Inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow


```

## Usage

### Scan a Single Host (Verifies Host is Alive First)
```powershell
.\ebony_ivory.ps1 -Target 192.168.1.50
```

### Sweep a Whole Local Network (Uses 3-Octet Base Range)
```powershell
.\ebony_ivory.ps1 -Target 192.168.1
```

### Run Specific Gun Modes
```powershell
# Ivory Only (TCP)
.\ebony_ivory.ps1 -Target 192.168.1.50 -Mode ivory

# Ebony Only (UDP)
.\ebony_ivory.ps1 -Target 192.168.1.50 -Mode ebony
```

## Protocol Limitations

Because this relies on standard user-mode `.NET` class calls rather than kernel-level packet injection:
- **TCP Scans** log full connections rather than half-open SYN packets. 
- **UDP Scans** cannot capture low-level raw ICMP rejection flags. Any port that absorbs traffic without explicit structural refusal is classified as `OPEN | FILTERED`.
