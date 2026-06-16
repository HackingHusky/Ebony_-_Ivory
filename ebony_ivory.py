#!/usr/bin/env python3 
import argparse 
import sys 
import logging 

# Shut up Scapy's generic startup warnings 
logging.getLogger("scapy.runtime").setLevel(logging.ERROR) 
from scapy.all import IP, TCP, UDP, ICMP, sr1

# Dante's Arsenal Config 
DEFAULT_TCP_PORTS = [21, 22, 23, 25, 53, 80, 88, 110, 139, 143, 443, 445, 389, 636, 1433, 3306, 3389, 5985] 
DEFAULT_UDP_PORTS = [53, 67, 68, 69, 123, 137, 138, 161, 514] 

def ping_check(target_ip):
    """Sends an ICMP Echo Request, falling back to a TCP SYN check if firewalled"""
    # Try traditional ICMP Ping first
    ping_packet = IP(dst=target_ip) / ICMP()
    response = sr1(ping_packet, timeout=0.8, verbose=False)
    if response is not None:
        return True
        
    # Fallback: Fire TCP SYN packets to common web/admin ports to bypass ICMP blocks
    # If the firewall allows these ports or the OS rejects the connection, it reveals the host is alive
    fallback_ports = [443, 80, 3389]
    for port in fallback_ports:
        tcp_ping = IP(dst=target_ip) / TCP(dport=port, flags="S")
        tcp_response = sr1(tcp_ping, timeout=0.5, verbose=False)
        
        # Receiving ANY TCP response (SYN-ACK or RST) proves the host is live
        if tcp_response and tcp_response.haslayer(TCP):
            return True
            
    return False

def ping_sweep(subnet):
    """Sweeps an entire CIDR network range for active hosts using smart detection"""
    print(f"[*] Commencing Host Sweep on network range: {subnet}")
    from scapy.utils import Net
    live_hosts = []
    
    try:
        for ip in Net(subnet):
            if ping_check(str(ip)):
                print(f"   [+] Host Detected: {ip}")
                live_hosts.append(str(ip))
    except Exception as e:
        print(f"[-] Error parsing subnet range: {e}")
        
    return live_hosts

def ivory_tcp_scan(target, port): 
    """Ivory: TCP SYN 'Half-Open' Scan""" 
    syn_packet = IP(dst=target) / TCP(dport=port, flags="S") 
    response = sr1(syn_packet, timeout=1.0, verbose=False) 
    
    if response: 
        if response.haslayer(TCP): 
            flags = response.getlayer(TCP).flags 
            if flags == 0x12: # SYN-ACK (Open) 
                rst_packet = IP(dst=target) / TCP(dport=port, flags="R") 
                sr1(rst_packet, timeout=0.5, verbose=False) 
                return "OPEN" 
            elif flags == 0x14: # RST-ACK (Closed) 
                return "CLOSED" 
    return "FILTERED/NO RESPONSE" 

def ebony_udp_scan(target, port): 
    """Ebony: UDP Port Unreachable Scan""" 
    udp_packet = IP(dst=target) / UDP(dport=port) 
    response = sr1(udp_packet, timeout=2.0, verbose=False) 
    
    if response is None: 
        return "OPEN | FILTERED (No response)" 
    elif response.haslayer(UDP): 
        return "OPEN" 
    elif response.haslayer(ICMP): 
        icmp_type = response.getlayer(ICMP).type 
        icmp_code = response.getlayer(ICMP).code 
        if int(icmp_type) == 3 and int(icmp_code) == 3: 
            return "CLOSED (ICMP Port Unreachable)" 
    return "UNKNOWN" 

def main(): 
    print(""" 
    ================================================== 
        EBONY & IVORY: Dual-Protocol Scanner 
              "It's showtime!" - Dante 
    ================================================== 
    """) 
    
    parser = argparse.ArgumentParser(description="Ebony & Ivory: Custom TCP/UDP Scapy Enumerator") 
    parser.add_argument("-t", "--target", required=True, help="Target IP address or Subnet range (e.g., 192.168.1.0/24)") 
    parser.add_argument("--mode", choices=["ivory", "ebony", "both"], default="both", help="ivory=TCP Only, ebony=UDP Only, both=Full Combo") 
    args = parser.parse_args() 
    
    target_input = args.target
    target_hosts = []

    if "/" in target_input:
        target_hosts = ping_sweep(target_input)
        if not target_hosts:
            print("[-] No live hosts answered the ICMP or TCP discovery probes. Exiting.")
            sys.exit(0)
        print(f"\n[*] Proceeding to enumerate {len(target_hosts)} live target(s)...")
    else:
        print(f"[*] Verifying host availability: {target_input}")
        if ping_check(target_input):
            print("   [+] Host is up!")
            target_hosts.append(target_input)
        else:
            print("[-] Target host did not respond to ICMP or TCP probes. Skipping execution.")
            sys.exit(0)

    for target in target_hosts:
        print(f"\n--------------------------------------------")
        print(f"Target Focus: {target}")
        print(f"--------------------------------------------")

        if args.mode in ["ivory", "both"]: 
            print(f"[Ivory] Firing TCP SYN shots...") 
            for port in DEFAULT_TCP_PORTS: 
                result = ivory_tcp_scan(target, port) 
                if result == "OPEN": 
                    print(f"   [+] TCP Port {port:<5} OPEN") 
                    
        if args.mode in ["ebony", "both"]: 
            print(f"\n[Ebony] Firing UDP probe shots...") 
            for port in DEFAULT_UDP_PORTS: 
                result = ebony_udp_scan(target, port) 
                if "OPEN" in result: 
                    print(f"   [+] UDP Port {port:<5} {result}") 
                
    print("\n[*] Jackpot! Scan sequence completed successfully.") 

if __name__ == "__main__": 
    import os 
    if os.geteuid() != 0: 
        print("[-] Error: Ebony & Ivory require Smokin' Sexy Style privileges! Run with sudo.") 
        sys.exit(1) 
    main()
