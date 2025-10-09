#!/bin/bash
# Script to create a new admin user for Wazuh

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./create-admin-user.sh <username> <password>"
    echo "Example: ./create-admin-user.sh myadmin MySecurePassword123!"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"

echo "Creating new admin user: $USERNAME"

curl -k -u admin:admin -X PUT "https://localhost:9200/_plugins/_security/api/internalusers/$USERNAME" \
  -H 'Content-Type: application/json' \
  -d "{
    \"password\": \"$PASSWORD\",
    \"opendistro_security_roles\": [\"all_access\", \"security_manager\"],
    \"backend_roles\": [\"admin\"],
    \"attributes\": {}
  }"

echo ""
echo "✅ New admin user created!"
echo "Credentials:"
echo "  Username: $USERNAME"
echo "  Password: $PASSWORD"
echo ""
echo "You can now login with this user and it has full admin access."
