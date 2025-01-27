#!/usr/bin/env bash


set -e

CN_BASE="harvester_homelab"

cat > intermediate_ca.conf << EOF
[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign
EOF

cat > server.conf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.60.155
DNS.1 = harvester.harvey.lab
EOF

cat > server_no_san.conf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF

cat > client.conf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
IP.1 = 127.0.0.1
EOF

# Create a certificate authority
openssl genrsa -out rootKey.pem 2048
openssl req -x509 -new -nodes -key rootKey.pem -days 100000 -out rootCert.pem -subj "/CN=${CN_BASE}_ca"

# Create an intermediate certificate authority
openssl genrsa -out caKeyInter.pem 2048
openssl req -new -nodes -key caKeyInter.pem -days 1000 -out caCertInter.csr -subj "/CN=${CN_BASE}_intermediate_ca"
openssl x509 -req -in caCertInter.csr -CA rootCert.pem -CAkey rootKey.pem -CAcreateserial -out caCertInter.pem -days 1000 -extensions v3_ca -extfile intermediate_ca.conf

# Create a server certiticate with SHA256 signature signed by OK intermediate CA
openssl genrsa -out serverKey.pem 2048
openssl req -new -key serverKey.pem -out server.csr -subj "/CN=${CN_BASE}" -config server.conf
openssl x509 -req -in server.csr -CA caCertInter.pem -CAkey caKeyInter.pem -CAcreateserial -out serverCert.pem -days 1000 -extensions v3_req -extfile server.conf

# Create a client certiticate
# openssl genrsa -out clientKey.pem 2048
# openssl req -new -key clientKey.pem -out client.csr -subj "/CN=${CN_BASE}_client" -config client.conf
# openssl x509 -req -in client.csr -CA caCert.pem -CAkey caKey.pem -CAcreateserial -out clientCert.pem -days 1000 -extensions v3_req -extfile client.conf

# Create a CA chain
cat caCertInter.pem > fullchain.pem
cat caCert.pem >> fullchain.pem



