I'll help you set up BIND9 DNS server for your domain. Here's the complete configuration:

## 1. Install BIND9

```bash
# Update system
sudo apt update

# Install BIND9
sudo apt install bind9 bind9utils bind9-doc -y

# Enable and start BIND9
sudo systemctl enable bind9
sudo systemctl start bind9
```

## 2. Configure BIND9 Options

Edit the main BIND9 configuration file:

```bash
sudo nano /etc/bind/named.conf.options
```

Add this configuration:

```bind
options {
    directory "/var/cache/bind";
    
    // Listen on all interfaces
    listen-on { any; };
    listen-on-v6 { any; };
    
    // Allow queries from anywhere
    allow-query { any; };
    
    // Allow recursion for local networks
    recursion yes;
    allow-recursion { 
        localhost; 
        localnets;
    };
    
    // Forwarders for external DNS resolution
    forwarders {
        8.8.8.8;
        8.8.4.4;
        1.1.1.1;
    };
    
    // Security settings
    dnssec-validation auto;
    auth-nxdomain no;
    
    // Version hiding for security
    version "DNS Server";
    
    // Enable statistics
    statistics-file "/var/cache/bind/named.stats";
    
    // Enable query logging (optional)
    // querylog yes;
};
```

## 3. Create Zone Files Directory

```bash
# Create directory for zone files
sudo mkdir -p /etc/bind/zones
```

## 4. Create Forward Zone File

Create the forward lookup zone file:

```bash
sudo nano /etc/bind/zones/db.stoneb2b.ir
```

Add this content:

```bind
; BIND data file for stoneb2b.ir
$TTL    604800
@       IN      SOA     ns1.stoneb2b.ir. admin.stoneb2b.ir. (
                              2024102501 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL

; Name servers
@       IN      NS      ns1.stoneb2b.ir.
@       IN      NS      ns2.stoneb2b.ir.

; A records
@       IN      A       YOUR_SERVER_IP
www     IN      A       YOUR_SERVER_IP
ns1     IN      A       YOUR_SERVER_IP
ns2     IN      A       YOUR_SERVER_IP

; CNAME records (if needed)
; ftp    IN      CNAME   @
; mail   IN      CNAME   @

; MX record for email (if needed)
; @      IN      MX 10   mail.stoneb2b.ir.

; TXT records (for SSL, verification, etc.)
@       IN      TXT     "v=spf1 a mx -all"
```

Replace `YOUR_SERVER_IP` with your actual server IP address.

## 5. Create Reverse Zone File (Optional but Recommended)

Create the reverse lookup zone file:

```bash
sudo nano /etc/bind/zones/db.YOUR_IP_REVERSE
```

Replace `YOUR_IP_REVERSE` with your IP in reverse format. For example, if your IP is `192.168.1.10`, use `db.192.168.1`:

```bind
; BIND reverse data file for stoneb2b.ir
$TTL    604800
@       IN      SOA     ns1.stoneb2b.ir. admin.stoneb2b.ir. (
                              2024102501 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL

; Name servers
@       IN      NS      ns1.stoneb2b.ir.
@       IN      NS      ns2.stoneb2b.ir.

; PTR records
YOUR_LAST_OCTET    IN      PTR     stoneb2b.ir.
YOUR_LAST_OCTET    IN      PTR     ns1.stoneb2b.ir.
YOUR_LAST_OCTET    IN      PTR     ns2.stoneb2b.ir.
```

Replace `YOUR_LAST_OCTET` with the last octet of your IP address.

## 6. Configure Zone Definitions

Edit the local zones configuration:

```bash
sudo nano /etc/bind/named.conf.local
```

Add this content:

```bind
// Forward zone
zone "stoneb2b.ir" {
    type master;
    file "/etc/bind/zones/db.stoneb2b.ir";
};

// Reverse zone - replace with your network
zone "YOUR_IP_REVERSE.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.YOUR_IP_REVERSE";
};
```

For example, if your IP is `192.168.1.10`:
```bind
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.168.1";
};
```

## 7. Set Proper Permissions

```bash
# Set ownership and permissions
sudo chown bind:bind /etc/bind/zones/*

# Make zone files readable
sudo chmod 644 /etc/bind/zones/*
```

## 8. Test and Reload BIND9

```bash
# Check configuration syntax
sudo named-checkconf

# Check forward zone
sudo named-checkzone stoneb2b.ir /etc/bind/zones/db.stoneb2b.ir

# Check reverse zone (if configured)
sudo named-checkzone YOUR_IP_REVERSE.in-addr.arpa /etc/bind/zones/db.YOUR_IP_REVERSE

# Reload BIND9
sudo systemctl reload bind9

# Check status
sudo systemctl status bind9
```

## 9. Configure Firewall for DNS

```bash
# Allow DNS traffic (port 53)
sudo ufw allow 53/tcp
sudo ufw allow 53/udp

# If you need to allow DNS queries from external networks
sudo ufw allow from any to any port 53
```

## 10. Update System DNS Settings

Temporarily update your server's DNS resolver to use itself:

```bash
# Backup original resolv.conf
sudo cp /etc/resolv.conf /etc/resolv.conf.backup

# Set BIND as DNS resolver
sudo nano /etc/resolv.conf
```

Replace content with:
```
nameserver 127.0.0.1
nameserver 8.8.8.8
search stoneb2b.ir
```

## 11. Test DNS Resolution

```bash
# Test forward lookup
nslookup stoneb2b.ir localhost
nslookup www.stoneb2b.ir localhost
nslookup ns1.stoneb2b.ir localhost

# Test reverse lookup (if configured)
nslookup YOUR_SERVER_IP localhost

# Test using dig
dig @localhost stoneb2b.ir
dig @localhost www.stoneb2b.ir

# Test external resolution
dig stoneb2b.ir
```

## 12. Update Domain Registrar DNS

You need to update your domain registrar's nameservers to point to your BIND9 server:

Go to your domain registrar's control panel and set:
```
Nameserver 1: ns1.stoneb2b.ir
Nameserver 2: ns2.stoneb2b.ir
```

You may also need to set **glue records** at your registrar for the nameservers.

## 13. Monitor BIND9

```bash
# Check BIND9 status
sudo systemctl status bind9

# View BIND9 logs
sudo tail -f /var/log/syslog | grep named

# Check query statistics
sudo rndc stats
sudo cat /var/cache/bind/named.stats
```

## 14. Security Hardening (Optional)

```bash
# Create BIND chroot environment (optional)
sudo apt install bind9-chroot -y

# Set up DNS firewall rules
sudo ufw deny from any to any port 53
sudo ufw allow from your_trusted_network to any port 53
```

## 15. Complete Verification

After DNS propagation (can take 24-48 hours), test from external network:

```bash
# Test from external machine
nslookup stoneb2b.ir
nslookup www.stoneb2b.ir

# Test all records
dig stoneb2b.ir ANY
```

## Important Notes:

1. **Replace YOUR_SERVER_IP** with your actual server public IP address
2. **DNS propagation** can take up to 48 hours
3. **Backup zone files** regularly
4. **Update serial number** when making changes to zone files
5. **Monitor logs** for any DNS issues

## Quick Status Check Commands:

```bash
# Check BIND9
sudo systemctl status bind9

# Test DNS
nslookup stoneb2b.ir localhost
dig stoneb2b.ir

# Check logs
sudo journalctl -u bind9 -f
```

Your BIND9 DNS server should now be operational and serving DNS records for your domain. Remember to update the serial number in your zone files whenever you make changes!