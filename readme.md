# Homelab Infrastructure as Code

Automated, containerized homelab infrastructure using Docker Swarm and Portainer for orchestration and management.

## Overview

This repository contains a complete homelab setup with four main stacks providing networking, security monitoring, file collaboration, and media automation services. All stacks are deployed as Docker Swarm services via Portainer, with the core stack providing the foundation for the entire infrastructure.

**Domain:** silentgarden.org

## Architecture

### Infrastructure Layers

```
                           Internet
                              |
                              v
            +------------------------------------+
            |         CORE STACK                 |
            |       (Primary Server)             |
            |                                    |
            |       +------------------+         |
            |       |  Cloudflared     |<----+   |
            |       |  (CF Tunnel)     |     |   |
            |       +--------+---------+  External
            |                |            Access |
            |       +--------v---------+     |   |
            |       |     Traefik      |-----+   |
            |       | (Reverse Proxy)  |         |
            |       +------------------+         |
            |                |                   |
            |       +--------v---------+         |
            |       |    Portainer     |         |
            |       | (Stack Manager)  |         |
            |       +------------------+         |
            +------------------------------------+
                              |
            +-----------------+-----------------+
            |                 |                 |
     +------v------+   +------v------+   +------v------+
     |  SECURITY   |   |   OFFICE    |   |    MEDIA    |
     |   STACK     |   |    STACK    |   |   SERVER    |
     |             |   |             |   |             |
     | - Wazuh     |   | - Seafile   |   | - Jellyfin  |
     |   Indexer   |   | - MariaDB   |   | - Sonarr    |
     | - Wazuh     |   | - Memcached |   | - Radarr    |
     |   Manager   |   |             |   | - qBit      |
     | - Wazuh     |   |             |   | - Prowlarr  |
     |   Dashboard |   |             |   | - Tdarr     |
     |             |   |             |   | - Gluetun   |
     +-------------+   +-------------+   +-------------+
                              |
                              | DNS Queries
                              |
            +-----------------v-----------------+
            |          DNS STACK                |
            |       (Proxmox Host)              |
            |                                   |
            |       +------------------+        |
            |       |     Pi-hole      |        |
            |       |  (DNS Server)    |        |
            |       +------------------+        |
            |                |                  |
            |       +--------v---------+        |
            |       |    Unbound       |        |
            |       | (Recursive DNS)  |        |
            |       +------------------+        |
            +-----------------------------------+
                              |
                    Network-wide DNS
```

### Stack Responsibilities

#### Core Stack (Foundation)
**Location:** `homelab/stacks/core/`

The foundational layer providing networking, routing, and orchestration services:

- **Traefik:** Reverse proxy with automatic service discovery (Swarm-aware)
- **Portainer:** Swarm cluster management UI for deploying stacks
- **Cloudflared:** Secure tunnel for remote access via Cloudflare

**Deploy first** - Initializes Docker Swarm and provides management interface for other stacks.

**Swarm Configuration:**
- Overlay network: `core_edge`
- Services with rolling updates
- Health checks and automatic recovery

#### Security Stack
**Location:** `homelab/stacks/security/`

Security monitoring and threat detection platform:

- **Wazuh Indexer:** OpenSearch-based data storage and search
- **Wazuh Manager:** Security event processing and analysis
- **Wazuh Dashboard:** Web interface for security monitoring

**Features:**
- Real-time threat detection
- File integrity monitoring
- Log analysis
- Compliance reporting (PCI-DSS, HIPAA, GDPR)
- Automated certificate and password management

#### Office Stack
**Location:** `homelab/stacks/office/`

File synchronization and collaboration platform:

- **Seafile:** Self-hosted file sync and share
- **MariaDB:** Database backend
- **Memcached:** Caching layer

**Features:**
- Cross-device file synchronization
- Web-based file management
- Collaboration and sharing
- Version control
- File encryption

#### Media Server Stack
**Location:** `homelab/stacks/media-server/`

Automated media management with VPN-protected downloads:

**Download Automation:**
- **Gluetun:** VPN client with kill switch
- **qBittorrent:** Torrent client (VPN-protected)
- **SABnzbd:** Usenet client (VPN-protected)
- **Prowlarr:** Indexer manager
- **FlareSolverr:** Cloudflare bypass

**Content Automation:**
- **Sonarr:** TV show management
- **Radarr:** Movie management
- **Headphones:** Music management

**Media Processing:**
- **Tdarr:** Automated transcoding
- **Tdarr Node:** Distributed processing

**Streaming & Management:**
- **Jellyfin:** Media streaming server
- **Jellyseerr:** Media request management
- **Homarr:** Service dashboard

#### DNS Stack
**Location:** `homelab/stacks/dns/`

Network-wide DNS and ad-blocking deployed on separate Proxmox host:

- **Pi-hole:** Network-level ad blocking and DNS server
- **Unbound:** Recursive DNS resolver for privacy

**Features:**
- Network-wide ad and tracker blocking
- Custom DNS records for local services
- DHCP server (optional)
- DNS-based service discovery
- Query logging and statistics
- Recursive DNS resolution (no third-party DNS)
- DNSSEC validation
- Cross-network DNS resolution

**Network Integration:**
- Provides DNS for both Proxmox network and primary server network
- Resolves local service hostnames (e.g., `portainer.silentgarden.org`, `jellyfin.silentgarden.org`)
- Enables seamless communication between stacks across networks
- Acts as primary DNS for all homelab devices

## Directory Structure

```
homelab-iac/
├── readme.md                          # This file
├── .gitignore
└── homelab/
    └── stacks/
        ├── core/                      # Core infrastructure
        │   ├── docker-compose.yaml
        │   ├── .env.example
        │   └── README.md
        │
        ├── security/                  # Wazuh security stack
        │   ├── docker-compose.yml
        │   ├── config/
        │   ├── README.md
        │   ├── PORTAINER_DEPLOYMENT.md
        │   ├── DEPLOYMENT_NOTES.md
        │   └── BACKUP_STRATEGY.md
        │
        ├── office/                    # Seafile office stack
        │   ├── docker-compose.yml
        │   └── README.md
        │
        ├── media-server/              # Media automation stack
        │   ├── docker-compose.yml
        │   └── README.md
        │
        └── dns/                       # Pi-hole DNS stack (Proxmox)
            ├── docker-compose.yml
            ├── .env.example
            ├── custom.list            # Local DNS records
            └── README.md
```

## Prerequisites

### System Requirements

**Primary Server (Core, Security, Office, Media):**
- **OS:** Linux-based system (Ubuntu, Debian, etc.)
- **Docker Engine:** 20.10 or higher (with Swarm mode enabled)
- **RAM:** Minimum 8GB (16GB+ recommended)
- **Storage:** Minimum 50GB (more for media storage)
- **Network:** Static IP or DDNS for external access

**DNS Server (Proxmox Host):**
- **OS:** Proxmox VE 7.0+ or any Linux system with Docker support
- **Docker Engine:** 20.10 or higher
- **RAM:** Minimum 2GB (4GB recommended)
- **Storage:** 10GB minimum
- **Network:** Static IP required (will be primary DNS server)
- **Network Access:** Must be reachable from primary server network

### Required Accounts/Subscriptions

- **Cloudflare Account:** For tunnel setup (free tier available)
- **VPN Subscription:** For media stack (Wireguard or OpenVPN compatible)
- **Git Repository:** GitHub, GitLab, or self-hosted for Portainer deployment

## Quick Start

### Step 1: Initialize Docker Swarm and Deploy Core Stack

The core stack must be deployed first as it initializes Docker Swarm and provides Portainer for managing other stacks.

```bash
# Clone the repository
git clone <your-repo-url>
cd homelab-iac/homelab/stacks/core

# Initialize Docker Swarm (if not already done)
docker swarm init --advertise-addr <primary-server-ip>

# Create environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
# Required:
# - CLOUDFLARE_TUNNEL_TOKEN (from Cloudflare dashboard)
# - TZ (your timezone)
# - DOMAIN=silentgarden.org

# Create Docker secrets for sensitive data
echo "your_cloudflare_tunnel_token" | docker secret create cloudflare_tunnel_token -
echo "your_secure_portainer_password" | docker secret create portainer_password -

# Create overlay network for core services
docker network create --driver overlay --attachable core_edge

# Deploy core stack
docker stack deploy -c docker-compose.yml core

# Verify deployment
docker stack services core
docker service ls

# Check service logs
docker service logs core_traefik
docker service logs core_portainer

# Access Portainer
# Local: http://localhost:9000
# Domain: https://portainer.silentgarden.org (via Traefik)
```

**Initial Portainer Setup:**

1. Access Portainer at `http://localhost:9000` or `https://portainer.silentgarden.org`
2. Create admin user account
3. Select **Docker Swarm** environment
4. Connect to local Swarm cluster
5. Configure Git repository for stack deployments

### Step 1.5: Deploy DNS Stack (Proxmox Host)

The DNS stack is deployed standalone on your Proxmox host (not part of the Swarm cluster) to provide network-wide DNS services.

```bash
# SSH into your Proxmox host or DNS server
ssh user@proxmox-host

# Clone the repository
git clone <your-repo-url>
cd homelab-iac/homelab/stacks/dns

# Create environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
# Required:
# - PIHOLE_DNS_1=127.0.0.1#5335  (Unbound)
# - PIHOLE_DNS_2=1.1.1.1          (Fallback)
# - WEBPASSWORD=your_secure_password
# - TZ=America/New_York
# - SERVERIP=<static-ip-of-this-host>
# - VIRTUAL_HOST=pihole.silentgarden.org

# Create custom DNS records file
nano custom.list
# Add local DNS entries:
# 192.168.1.10    portainer.silentgarden.org
# 192.168.1.10    traefik.silentgarden.org
# 192.168.1.10    jellyfin.silentgarden.org
# 192.168.1.10    sonarr.silentgarden.org
# <add your service IPs and hostnames>

# Deploy DNS services (using docker-compose, not Swarm)
docker-compose up -d

# Verify deployment
docker-compose ps

# Check Pi-hole is responding
dig @127.0.0.1 google.com
```

**Initial Pi-hole Setup:**

1. Access Pi-hole admin at `http://<proxmox-ip>/admin` or `http://pihole.silentgarden.org/admin`
2. Login with your `WEBPASSWORD`
3. Navigate to **Settings** → **DNS**
   - Verify Unbound is set as upstream DNS (127.0.0.1#5335)
4. Navigate to **Local DNS** → **DNS Records**
   - Verify custom.list entries are loaded
5. Configure your router to use Pi-hole as primary DNS:
   - Primary DNS: `<proxmox-ip>`
   - Secondary DNS: `1.1.1.1` (fallback)
6. Or manually configure DNS on primary server:
   ```bash
   # Edit /etc/resolv.conf on primary server
   nameserver <proxmox-ip>
   nameserver 1.1.1.1
   ```

### Step 2: Deploy Additional Stacks via Portainer

Once the core stack is running, deploy other stacks through Portainer's Swarm management interface.

#### General Portainer Swarm Stack Deployment Process

For each stack (security, office, media-server):

1. **In Portainer UI:**
   - Navigate to **Stacks** → **Add stack**
   - Select **Repository** as build method

2. **Configure Repository:**
   - Repository URL: Your Git repository URL
   - Repository reference: `main` (or your branch)
   - Compose path: `homelab/stacks/<stack-name>/docker-compose.yml`
   - Enable automatic updates (optional)

3. **Set Environment Variables:**
   - Add required variables (see stack-specific sections below)
   - Use Portainer's environment variable editor
   - Consider using Docker Secrets for sensitive data

4. **Deploy as Swarm Stack:**
   - Click "Deploy the stack"
   - Portainer will deploy services to the Swarm cluster
   - Monitor logs for deployment progress
   - Services will be distributed with defined replicas and placement

**Swarm Benefits:**
- Automatic service recovery and restart
- Rolling updates with zero downtime
- Service scaling and load balancing
- Overlay networking for service communication
- Secrets management for sensitive data

#### Security Stack Deployment

**Compose path:** `homelab/stacks/security/docker-compose.yml`

**Environment Variables:**
```
INDEXER_PASSWORD=your_secure_password
API_PASSWORD=your_api_password
```

**Post-deployment:**
- Access: `http://<docker-host>:5601`
- Login: `admin` / (value of INDEXER_PASSWORD)
- See `security/README.md` for detailed configuration

#### Office Stack Deployment

**Compose path:** `homelab/stacks/office/docker-compose.yml`

**Required Environment Variables:**
```
INIT_SEAFILE_MYSQL_ROOT_PASSWORD=strong_root_password
SEAFILE_MYSQL_DB_PASSWORD=seafile_db_password
JWT_PRIVATE_KEY=<generate with: openssl rand -base64 32>
INIT_SEAFILE_ADMIN_EMAIL=admin@yourdomain.com
INIT_SEAFILE_ADMIN_PASSWORD=admin_password
SEAFILE_SERVER_HOSTNAME=seafile.yourdomain.com
SEAFILE_SERVER_PROTOCOL=http
```

**Optional Variables:**
```
SEAFILE_HTTP_PORT=8081
TIME_ZONE=America/New_York
```

**Post-deployment:**
- Access: `http://<docker-host>:8081`
- See `office/README.md` for configuration

#### Media Server Stack Deployment

**Compose path:** `homelab/stacks/media-server/docker-compose.yml`

**Pre-deployment:** Create directory structure on Docker host:

```bash
export BASE_PATH=/path/to/media/storage
mkdir -p ${BASE_PATH}/{config/{qbittorrent,prowlarr,sonarr,radarr,sabnzbd,headphones,jellyseerr,jellyfin},media/{downloads,tv-shows,movies,music,books},tdarr/{server,configs,logs},transcode,homarr/icons,gluetun}
chown -R 1000:1000 ${BASE_PATH}
```

**Required Environment Variables:**
```
BASE_PATH=/path/to/media/storage
VPN_SERVICE_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=your_private_key
WIREGUARD_ADDRESSES=10.x.x.x/32
WIREGUARD_ENDPOINT=endpoint.server.com:51820
WIREGUARD_PUBLIC_KEY=provider_public_key
PUID=1000
PGID=1000
TZ=America/New_York
```

**Post-deployment:**
- Verify VPN connection in Gluetun logs
- Access services (see `media-server/README.md`)
- Configure automation services

#### DNS Stack Configuration (Manual)

The DNS stack is deployed directly on the Proxmox host (not via Portainer) as described in **Step 1.5**.

**Post-Deployment Configuration:**

1. **Add Local DNS Records:**
   - Edit `custom.list` on Proxmox host
   - Add entries for all homelab services
   - Restart Pi-hole: `docker compose restart pihole`

2. **Configure Cross-Network DNS:**
   - Ensure primary server uses Proxmox host as DNS
   - Verify resolution: `nslookup portainer.local <proxmox-ip>`

3. **Enable Conditional Forwarding (Optional):**
   - In Pi-hole admin: **Settings** → **DNS** → **Conditional Forwarding**
   - Local network: `192.168.1.0/24` (your network)
   - Router IP: Your router address
   - Local domain: `local`

4. **Verify Cross-Network Communication:**
   ```bash
   # From primary server, test DNS resolution
   ping jellyfin.local
   ping portainer.local
   
   # From any device on network
   ping pihole.local
   ```

## Service Access Points

### Core Stack

| Service | URL | Purpose |
|---------|-----|---------|
| Portainer | `http://localhost:9000` | Container management |
| Traefik | `http://localhost:80` | Reverse proxy (routing only) |

### Security Stack

| Service | URL | Purpose |
|---------|-----|---------|
| Wazuh Dashboard | `http://<host>:5601` | Security monitoring UI |
| Wazuh API | `http://<host>:55000` | REST API |
| Wazuh Indexer | `https://<host>:9200` | OpenSearch API |

### Office Stack

| Service | URL | Purpose |
|---------|-----|---------|
| Seafile | `http://<host>:8081` | File management web UI |

### Media Server Stack

| Service | URL | Purpose |
|---------|-----|---------|
| Homarr | `http://<host>:7575` | Service dashboard |
| Jellyfin | `http://<host>:8096` | Media streaming |
| Jellyseerr | `http://<host>:5055` | Media requests |
| Sonarr | `http://<host>:8989` | TV show management |
| Radarr | `http://<host>:7878` | Movie management |
| Prowlarr | `http://<host>:9696` | Indexer management |
| qBittorrent | `http://<host>:8282` | Torrent client |
| Tdarr | `http://<host>:8265` | Media transcoding |

### DNS Stack

| Service | URL | Purpose |
|---------|-----|---------|
| Pi-hole Admin | `http://<proxmox-ip>/admin` | DNS management UI |
| Pi-hole DNS | `<proxmox-ip>:53` | DNS server |
| Unbound | `127.0.0.1:5335` | Recursive DNS resolver |

## Network Architecture

### Network Isolation

Each stack uses Docker Swarm overlay networks for service communication:

- **Core:** `core_edge` overlay network (attachable)
- **Security:** `security_net` overlay network
- **Office:** `seafile-net` overlay network
- **Media Server:** Mixed
  - `media_net` overlay network for inter-service communication
  - VPN services use `service:gluetun` network mode
  - Services attached to `core_edge` for Traefik routing
- **DNS Stack:** `pihole-net` bridge network (standalone on Proxmox host)

**Overlay Network Benefits:**
- Automatic service discovery across Swarm nodes
- Encrypted inter-service communication
- Network segmentation and isolation
- Load balancing for replicated services
- Support for multi-host deployments

### Cross-Network Communication

The DNS stack bridges both networks by providing centralized DNS services:

**Network Topology:**
```
┌─────────────────────────────────────────────────────┐
│                  Home Network                       │
│                  (192.168.1.0/24)                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │  Primary Server  │      │  Proxmox Host    │   │
│  │  (192.168.1.10)  │◄────►│  (192.168.1.20)  │   │
│  │                  │      │                  │   │
│  │  - Core Stack    │      │  - Pi-hole       │   │
│  │  - Security      │      │  - Unbound       │   │
│  │  - Office        │      │                  │   │
│  │  - Media         │      │  DNS: port 53    │   │
│  │                  │      │  Admin: port 80  │   │
│  └──────────────────┘      └──────────────────┘   │
│          │                          │              │
│          └──────────┬───────────────┘              │
│                     │                              │
│                     ▼                              │
│           All devices use Proxmox                  │
│           as primary DNS server                    │
└─────────────────────────────────────────────────────┘
```

**DNS Resolution Flow:**
1. Device queries `jellyfin.local` → Pi-hole (192.168.1.20:53)
2. Pi-hole checks custom.list → Returns 192.168.1.10
3. Device connects to Jellyfin on primary server
4. External queries forwarded to Unbound for recursive resolution

**Benefits:**
- Services accessible by hostname across both networks
- Single point of DNS management
- Network-wide ad blocking
- Privacy through recursive DNS (no third-party DNS queries)

### Port Management

Port assignments are designed to avoid conflicts:

- **Core:** 80, 9000
- **Security:** 1514/udp, 1515, 514/udp, 5601, 9200, 55000
- **Office:** 8081
- **Media:** 5055, 6881, 7575, 7878, 8096, 8181, 8265-8267, 8282, 8989, 9696
- **DNS (Proxmox):** 53/tcp, 53/udp, 80 (Pi-hole admin), 5335 (Unbound)

### VPN Routing (Media Stack)

The media server stack uses Gluetun for VPN protection:

- **VPN-routed services:** qBittorrent, Prowlarr, Sonarr, Radarr, SABnzbd, Headphones, FlareSolverr
- **Direct services:** Jellyfin, Jellyseerr, Homarr, Tdarr
- **Kill switch:** Blocks internet if VPN disconnects

## Data Persistence

### Docker Volumes

Each stack manages its own volumes:

**Security Stack:**
- `wazuh-certs`: SSL/TLS certificates
- `wazuh-indexer-data`: OpenSearch data
- `wazuh-manager-config`: Manager configuration
- `wazuh-manager-logs`: Security logs
- `wazuh-manager-data`: Manager data

**Office Stack:**
- `./data/mysql`: Database files
- `./data/seafile`: File storage and metadata

**Media Server Stack:**
- All data stored under `${BASE_PATH}` directory
- Configuration, media, and working directories

**DNS Stack:**
- `pihole-data`: Pi-hole configuration and blocklists
- `pihole-dnsmasq`: DNS configuration files
- `unbound-data`: Unbound configuration and cache

### Backup Recommendations

Critical data to backup regularly:

- **Core:** Portainer data volume
- **Security:** All Wazuh volumes (especially logs and data)
- **Office:** MySQL and Seafile data directories
- **Media:** Configuration directories (not media files)
- **DNS:** Pi-hole configuration, custom.list, and blocklists

See individual stack README files for detailed backup procedures.

## Monitoring and Maintenance

### Health Checks

All critical services include health checks:

- Monitor via Portainer UI
- Check logs for issues: `docker logs <container-name>`

### Log Management

View logs for troubleshooting:

```bash
# Via Docker CLI
docker logs -f <container-name>

# Via Portainer UI
# Navigate to container → Logs
```

### Updates

**Core Stack (manual):**

```bash
cd homelab/stacks/core

# Pull latest images
docker service update --image traefik:latest core_traefik
docker service update --image portainer/portainer-ce:latest core_portainer

# Or redeploy entire stack
docker stack deploy -c docker-compose.yml core
```

**Other Stacks (via Portainer):**

- Enable automatic updates in stack configuration, or
- Manual update: **Stacks** → Select stack → **Update the stack**
- Portainer will perform rolling updates with zero downtime

## Troubleshooting

### Common Issues

#### Portainer Not Accessible

```bash
# Check core stack services
docker stack services core

# Check Portainer service specifically
docker service ls | grep portainer
docker service ps core_portainer

# Check Portainer logs
docker service logs core_portainer

# Verify port binding on Swarm node
netstat -tulpn | grep 9000
```

#### Stack Deployment Fails in Portainer

- Verify all required environment variables are set
- Check repository access and compose file path
- Review deployment logs in Portainer
- Ensure no port conflicts with other services

#### VPN Issues (Media Stack)

- Check Gluetun logs for connection status
- Verify VPN credentials in environment variables
- Test with different VPN server endpoint
- Ensure NET_ADMIN capability is granted

#### Service Can't Be Reached

- Verify service is running: `docker service ls`
- Check service status: `docker service ps <service-name>`
- Review service logs: `docker service logs <service-name>`
- Verify port mappings: `docker service inspect <service-name>`
- Check Swarm node status: `docker node ls`
- Verify overlay network: `docker network inspect <network-name>`
- Verify firewall rules

#### DNS Resolution Issues

**Symptoms:** Services not resolving by hostname, only IP works

```bash
# On primary server, check DNS configuration
cat /etc/resolv.conf
# Should show: nameserver <proxmox-ip>

# Test DNS resolution
nslookup jellyfin.local <proxmox-ip>
dig @<proxmox-ip> portainer.local

# Check Pi-hole status on Proxmox host
cd homelab/stacks/dns
docker compose ps
docker logs pihole

# Verify custom.list is loaded
docker exec pihole cat /etc/pihole/custom.list

# Restart Pi-hole if needed
docker compose restart pihole
```

**Common fixes:**
- Verify Proxmox host is reachable: `ping <proxmox-ip>`
- Check firewall isn't blocking port 53
- Ensure custom.list has correct entries
- Verify primary server DNS points to Proxmox
- Restart dnsmasq: `docker exec pihole pihole restartdns`

### Getting Help

- **Stack-specific issues:** See individual README files in each stack directory
- **Wazuh:** [Official Documentation](https://documentation.wazuh.com/)
- **Seafile:** [Seafile Manual](https://manual.seafile.com/)
- **Pi-hole:** [Pi-hole Documentation](https://docs.pi-hole.net/)
- **Media Stack Components:** Check individual project documentation

## Security Considerations

### Best Practices

- **Change Default Passwords:** Update all default credentials immediately
- **Use Strong Passwords:** Especially for exposed services
- **Enable HTTPS:** Use Traefik with Let's Encrypt for SSL
- **Regular Updates:** Keep all containers updated
- **Backup Regularly:** Implement automated backup strategy
- **Monitor Logs:** Use Wazuh for security monitoring
- **Network Segmentation:** Use Docker networks to isolate services
- **VPN Protection:** All download traffic routed through VPN
- **Secure DNS:** Pi-hole provides DNS-level security and privacy
- **DNSSEC:** Enable in Unbound for DNS validation

### Exposed Ports

Be cautious about exposing these ports to the internet:

- **9000 (Portainer):** Consider VPN or authentication
- **5601 (Wazuh):** Sensitive security data
- **8081 (Seafile):** Contains user files
- **53 (DNS):** Should only be accessible on local network
- **80 (Pi-hole Admin):** Use strong password, consider VPN
- **Media ports:** Use authentication for remote access

### Secrets Management

- Never commit `.env` files to Git (included in `.gitignore`)
- Use Portainer's environment variables for secrets
- Rotate passwords periodically
- Generate strong JWT keys and tokens

## Development

### Local Development

For local testing:

```bash
# Clone repository
git clone <repo-url>
cd homelab-iac

# Initialize Swarm (if testing Swarm locally)
docker swarm init

# Test individual stack
cd homelab/stacks/<stack-name>
docker stack deploy -c docker-compose.yml test_<stack-name>

# View services
docker stack services test_<stack-name>

# View logs
docker service logs test_<stack-name>_<service-name>

# Tear down
docker stack rm test_<stack-name>

# For non-Swarm testing (like DNS stack)
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Making Changes

1. Create feature branch
2. Test changes locally
3. Commit and push to repository
4. Portainer will auto-update (if enabled) or manually update stack

## License

This configuration uses multiple open-source components, each with their own licenses:

- **Traefik:** MIT
- **Portainer:** Zlib
- **Wazuh:** GPLv2
- **OpenSearch:** Apache 2.0
- **Seafile:** AGPLv3 / Commercial
- **MariaDB:** GPLv2
- **Jellyfin:** GPLv2
- **Sonarr/Radarr:** GPLv3

See individual project repositories for complete license information.

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly
4. Submit pull request with clear description

## Acknowledgments

Built with excellent open-source projects:

- [Traefik](https://traefik.io/)
- [Portainer](https://www.portainer.io/)
- [Wazuh](https://wazuh.com/)
- [Seafile](https://www.seafile.com/)
- [Pi-hole](https://pi-hole.net/)
- [Unbound](https://nlnetlabs.nl/projects/unbound/)
- [Jellyfin](https://jellyfin.org/)
- [Sonarr](https://sonarr.tv/), [Radarr](https://radarr.video/), [Prowlarr](https://prowlarr.com/)
- [Gluetun](https://github.com/qdm12/gluetun)
- And many more...
