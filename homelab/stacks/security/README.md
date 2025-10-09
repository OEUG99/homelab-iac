# Wazuh Security Stack

Wazuh is an open-source security monitoring platform for threat detection, integrity monitoring, incident response, and compliance.

## Services Status

### ✅ Wazuh Indexer (OpenSearch) - Port 9200
- Status: **Running and Healthy**
- Stores and indexes security event data
- Security plugin disabled for internal network use

### ✅ Wazuh Manager - Port 55000
- Status: **Running and Healthy**
- Collects and analyzes security events from agents
- Provides REST API for configuration and queries
- Ports:
  - `1514/udp`: Agent events
  - `1515/tcp`: Agent enrollment  
  - `514/udp`: Syslog collector
  - `55000/tcp`: REST API

### ✅ Wazuh Dashboard - Port 5601
- Status: **Running and Accessible**
- Web UI for visualizing security data
- Access at: http://localhost:5601

## Quick Start

```bash
# Start the stack
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f wazuh-manager
docker compose logs -f wazuh-indexer
docker compose logs -f wazuh-dashboard

# Stop the stack
docker compose down
```

## Access & Credentials

### Dashboard Login
- **URL**: http://localhost:5601
- **Default Username**: `admin`
- **Default Password**: Check `INDEXER_PASSWORD` in `.env` file

### API Access
Credentials are stored in `.env` file (keep secure!):

- **Indexer Password**: See `INDEXER_PASSWORD` in .env
- **API Password**: See `API_PASSWORD` in .env
- **API Username**: `wazuh-wui`

### Testing Connectivity

```bash
# Test indexer
curl http://localhost:9200

# Test dashboard
curl http://localhost:5601/status

# Test manager API (use credentials from .env)
curl -k -u wazuh-wui:YOUR_API_PASSWORD https://localhost:55000/
```

## Security Configuration

### Current Setup
- ✅ Strong random passwords (32+ characters)
- ✅ Isolated Docker network
- ✅ SSL/TLS disabled on indexer for simplicity
- ✅ Data persistence with Docker volumes
- ✅ Secure file permissions on .env (600)

### For Production Use
Consider enabling:
1. SSL/TLS certificates for all communications
2. OpenSearch security plugin
3. Firewall rules to limit external access
4. Regular backups of volumes
5. Password rotation policy
6. Custom admin credentials

## Volumes

Data is persisted in the following Docker volumes:
- `wazuh-indexer-data`: OpenSearch indices and data
- `wazuh-manager-config`: Manager configuration files
- `wazuh-manager-logs`: Manager log files  
- `wazuh-manager-data`: Manager runtime data

## Adding Agents

To monitor other systems, install Wazuh agents and point them to your manager:

```bash
# On Ubuntu/Debian
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get install wazuh-agent

# Configure agent to point to your manager
echo "WAZUH_MANAGER='YOUR_MANAGER_IP'" >> /var/ossec/etc/ossec.conf

# Start agent
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

## Troubleshooting

### View Logs
```bash
docker compose logs wazuh-dashboard --tail 100
docker compose logs wazuh-manager --tail 100
docker compose logs wazuh-indexer --tail 100
```

### Restart Services
```bash
docker compose restart wazuh-dashboard
docker compose restart wazuh-manager
docker compose restart wazuh-indexer
```

### Can't Access Dashboard
1. Verify the container is running: `docker compose ps`
2. Check logs: `docker compose logs wazuh-dashboard`
3. Ensure port 5601 is not in use: `lsof -i :5601`
4. Try accessing: `curl http://localhost:5601/status`

### Authentication Issues
The dashboard uses the indexer credentials. Default login:
- Username: `admin`
- Password: Value of `INDEXER_PASSWORD` from `.env` file

## Architecture

```
┌─────────────────┐
│ Wazuh Dashboard │ :5601
│   (Web UI)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│ Wazuh Manager   │◄────►│  Wazuh Agents    │
│   (Analysis)    │ :1514│ (Endpoints)      │
└────────┬────────┘ :1515└──────────────────┘
         │
         ▼
┌─────────────────┐
│ Wazuh Indexer   │ :9200
│  (OpenSearch)   │
└─────────────────┘
```

## Configuration Files

- `docker-compose.yml`: Service definitions
- `.env`: Credentials (gitignored)
- `opensearch_dashboards.yml`: Dashboard configuration
- `indexer-config.yml`: Indexer configuration

## Notes

- Security plugin disabled on indexer for simplicity - enable for production
- No TLS/SSL configured - suitable for internal networks only
- Keep `.env` file secure and never commit to version control
- Dashboard takes ~2 minutes to fully start up
- All passwords are randomly generated and stored in `.env`

## Support

- Official Documentation: https://documentation.wazuh.com/
- Community Forum: https://groups.google.com/g/wazuh
- GitHub Issues: https://github.com/wazuh/wazuh
