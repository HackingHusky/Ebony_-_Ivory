<#
.SYNOPSIS
    Ebony & Ivory: Dual-Protocol Network Scanner
.DESCRIPTION
    A custom network enumeration script built on native .NET sockets.
    Ivory handles TCP handshakes, while Ebony fires UDP probes.
#>

# Dante's Arsenal Config
$DEFAULT_TCP_PORTS = @(21, 22, 23, 25, 53, 80, 88, 110, 139, 143, 443, 445, 389, 636, 3306, 3389, 5985)
$DEFAULT_UDP_PORTS = @(53, 67, 68, 69, 123, 137, 138, 161, 514)

param (
    [Parameter(Mandatory=$true, HelpMessage="Target IP address or 3-octet base network (e.g., 192.168.1)")]
    [string]$Target,

    [Parameter(Mandatory=$false)]
    [ValidateSet("ivory", "ebony", "both")]
    [string]$Mode = "both",

    [Parameter(Mandatory=$false)]
    [int]$TimeoutMs = 1000
)

function Write-Banner {
    Write-Output "=================================================="
    Write-Output "  EBONY & IVORY: Dual-Protocol Scanner (PowerShell)"
    Write-Output "          `"It's showtime!`" - Dante            "
    Write-Output "=================================================="
    Write-Output ""
}

function Invoke-IvoryTcpScan {
    param ([string]$CurrentHost)
    Write-Output "[Ivory] Firing TCP shots at $CurrentHost..."
    
    foreach ($port in $DEFAULT_TCP_PORTS) {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        # Use async connection pattern to safely apply custom millisecond timeout ceilings
        $asyncResult = $tcpClient.BeginConnect($CurrentHost, $port, $null, $null)
        $wait = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $true)
        
        if ($wait -and $tcpClient.Connected) {
            Write-Output "   [+] TCP Port $port OPEN"
            $tcpClient.Close()
        } else {
            $tcpClient.Close()
        }
    }
}

function Invoke-EbonyUdpScan {
    param ([string]$CurrentHost)
    Write-Output "`n[Ebony] Firing UDP probe shots at $CurrentHost..."
    
    foreach ($port in $DEFAULT_UDP_PORTS) {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        try {
            $udpClient.Connect($CurrentHost, $port)
            # UDP is connectionless; we write a tiny structural payload to confirm socket registration
            $sendBytes = [System.Text.Encoding]::ASCII.GetBytes("ping")
            [void]$udpClient.Send($sendBytes, $sendBytes.Length)
            
            # Since standard unprivileged .NET lacks raw ICMP packet sniffing capabilities,
            # connection availability flags it as an OPEN | FILTERED endpoint state.
            Write-Output "   [+] UDP Port $port OPEN | FILTERED"
        } catch {
            # Closed or rejected sockets trigger exception block responses
        } finally {
            $udpClient.Close()
        }
    }
}

# --- Execution Entry ---
Clear-Host
Write-Banner

$targetHosts = @()

# Detect if the target input matches a 3-octet network pool string (e.g., 192.168.1)
if ($Target -match '^[0-9]+\.[0-9]+\.[0-9]+$') {
    Write-Output "[*] Commencing Ping Sweep on network range: ${Target}.1-254"
    $ping = New-Object System.Net.NetworkInformation.Ping
    
    for ($i = 1; $i -le 254; $i++) {
        $ip = "${Target}.${i}"
        try {
            $reply = $ping.Send($ip, $TimeoutMs)
            if ($reply.Status -eq "Success") {
                Write-Output "   [+] Host Detected: $ip"
                $targetHosts += $ip
            }
        } catch {}
    }
    
    if ($targetHosts.Count -eq 0) {
        Write-Output "[-] No live hosts found during the ping sweep. Exiting."
        exit
    }
    Write-Output "`n[*] Proceeding to enumerate $($targetHosts.Count) live target(s)..."
} else {
    # Check single host availability
    Write-Output "[*] Verifying host availability via ping: $Target"
    $ping = New-Object System.Net.NetworkInformation.Ping
    try {
        $reply = $ping.Send($Target, $TimeoutMs)
        if ($reply.Status -eq "Success") {
            Write-Output "   [+] Host is up!"
            $targetHosts += $Target
        } else {
            Write-Output "[-] Target host did not respond to ping. Skipping execution."
            exit
    }
    } catch {
        Write-Output "[-] Error communicating with target. Skipping execution."
        exit
    }
}

# Execute protocol scan rotations
foreach ($hostFocus in $targetHosts) {
    Write-Output "`n--------------------------------------------"
    Write-Output "Target Focus: $hostFocus"
    Write-Output "--------------------------------------------"
    
    if ($Mode -eq "ivory" -or $Mode -eq "both") {
        Invoke-IvoryTcpScan -CurrentHost $hostFocus
    }
    if ($Mode -eq "ebony" -or $Mode -eq "both") {
        Invoke-EbonyUdpScan -CurrentHost $hostFocus
    }
}

Write-Output "`n[*] Jackpot! Scan sequence completed successfully."
