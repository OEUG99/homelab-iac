#!/bin/bash
set -e

CERT_DIR="./certs"
rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"

echo "Generating Root CA..."
openssl genrsa -out "$CERT_DIR/root-ca-key.pem" 2048
openssl req -new -x509 -sha256 -key "$CERT_DIR/root-ca-key.pem" -subj "/C=US/ST=CA/L=SF/O=Wazuh/CN=root" -out "$CERT_DIR/root-ca.pem" -days 730

echo "Generating Admin cert..."
openssl genrsa -out "$CERT_DIR/admin-key-temp.pem" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$CERT_DIR/admin-key-temp.pem" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$CERT_DIR/admin-key.pem"
openssl req -new -key "$CERT_DIR/admin-key.pem" -subj "/C=US/ST=CA/L=SF/O=Wazuh/CN=admin" -out "$CERT_DIR/admin.csr"
openssl x509 -req -in "$CERT_DIR/admin.csr" -CA "$CERT_DIR/root-ca.pem" -CAkey "$CERT_DIR/root-ca-key.pem" -CAcreateserial -sha256 -out "$CERT_DIR/admin.pem" -days 730

echo "Generating Indexer cert..."
openssl genrsa -out "$CERT_DIR/indexer-key-temp.pem" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$CERT_DIR/indexer-key-temp.pem" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$CERT_DIR/indexer-key.pem"
openssl req -new -key "$CERT_DIR/indexer-key.pem" -subj "/C=US/ST=CA/L=SF/O=Wazuh/CN=wazuh-indexer" -out "$CERT_DIR/indexer.csr"
openssl x509 -req -in "$CERT_DIR/indexer.csr" -CA "$CERT_DIR/root-ca.pem" -CAkey "$CERT_DIR/root-ca-key.pem" -CAcreateserial -sha256 -out "$CERT_DIR/indexer.pem" -days 730 -extensions v3_req -extfile <(cat <<END
[v3_req]
subjectAltName = DNS:wazuh-indexer,DNS:localhost,IP:127.0.0.1
END
)

echo "Generating Dashboard cert..."
openssl genrsa -out "$CERT_DIR/dashboard-key-temp.pem" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$CERT_DIR/dashboard-key-temp.pem" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$CERT_DIR/dashboard-key.pem"
openssl req -new -key "$CERT_DIR/dashboard-key.pem" -subj "/C=US/ST=CA/L=SF/O=Wazuh/CN=wazuh-dashboard" -out "$CERT_DIR/dashboard.csr"
openssl x509 -req -in "$CERT_DIR/dashboard.csr" -CA "$CERT_DIR/root-ca.pem" -CAkey "$CERT_DIR/root-ca-key.pem" -CAcreateserial -sha256 -out "$CERT_DIR/dashboard.pem" -days 730

echo "Generating Filebeat cert..."
openssl genrsa -out "$CERT_DIR/filebeat-key-temp.pem" 2048
openssl pkcs8 -inform PEM -outform PEM -in "$CERT_DIR/filebeat-key-temp.pem" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "$CERT_DIR/filebeat-key.pem"
openssl req -new -key "$CERT_DIR/filebeat-key.pem" -subj "/C=US/ST=CA/L=SF/O=Wazuh/CN=filebeat" -out "$CERT_DIR/filebeat.csr"
openssl x509 -req -in "$CERT_DIR/filebeat.csr" -CA "$CERT_DIR/root-ca.pem" -CAkey "$CERT_DIR/root-ca-key.pem" -CAcreateserial -sha256 -out "$CERT_DIR/filebeat.pem" -days 730

# Cleanup temp files
rm -f "$CERT_DIR"/*.csr "$CERT_DIR"/*-temp.pem "$CERT_DIR"/*.srl

# Set permissions
chmod 644 "$CERT_DIR"/*.pem

echo "Certificates generated successfully in $CERT_DIR/"
ls -lh "$CERT_DIR"
