#!/bin/bash
# Script to reset the reserved admin password

if [ -z "$1" ]; then
    echo "Usage: ./reset-admin-password.sh <new_password>"
    exit 1
fi

NEW_PASSWORD="$1"

echo "Generating password hash..."
HASH=$(docker compose exec -T wazuh-indexer bash -c "export JAVA_HOME=/usr/share/wazuh-indexer/jdk && /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p '$NEW_PASSWORD'" | tr -d '\r')

echo "Updating internal_users.yml..."
docker compose exec -T wazuh-indexer bash -c "cat > /tmp/internal_users.yml << 'EOFCONFIG'
---
_meta:
  type: \"internalusers\"
  config_version: 2

admin:
  hash: \"$HASH\"
  reserved: true
  backend_roles:
  - \"admin\"
  description: \"Admin user\"
EOFCONFIG
"

echo "Applying configuration..."
docker compose exec -T wazuh-indexer bash -c "
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
cd /usr/share/wazuh-indexer/plugins/opensearch-security/tools
./securityadmin.sh \
  -f /tmp/internal_users.yml \
  -t internalusers \
  -icl -nhnv \
  -cacert /usr/share/wazuh-indexer/certs/root-ca.pem \
  -cert /usr/share/wazuh-indexer/certs/admin.pem \
  -key /usr/share/wazuh-indexer/certs/admin-key.pem \
  -h localhost
"

echo ""
echo "✅ Admin password has been reset!"
echo "New credentials:"
echo "  Username: admin"
echo "  Password: $NEW_PASSWORD"
echo ""
echo "Don't forget to update .env and restart services:"
echo "  1. Update INDEXER_PASSWORD in .env"
echo "  2. Run: docker compose restart wazuh-manager wazuh-dashboard"
