#!/bin/bash
set -e

rm -rf certs
mkdir -p certs
cd certs

echo "1. Kök Sertifika Otoritesi (CA) oluşturuluyor..."
openssl genrsa -out ca.key 4096

# CA config dosyası oluştur
cat > ca.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
C = TR
ST = Istanbul
L = Istanbul
O = Sentiric
CN = Sentiric Root CA

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = critical,digitalSignature,keyCertSign,cRLSign
EOF

openssl req -new -x509 -sha256 -days 3650 -key ca.key -out ca.crt -config ca.cnf

echo "2. Servis sertifikaları oluşturuluyor..."

for SERVICE in postgres rabbitmq user-service agent-service dialplan-service media-service sip-signaling sip-gateway llm-service
do
  echo "--- $SERVICE için sertifika oluşturuluyor ---"
  
  # Özel anahtar ve CSR
  openssl genrsa -out $SERVICE.key 4096
  
  cat > $SERVICE.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = TR
ST = Istanbul
L = Istanbul
O = Sentiric
CN = $SERVICE

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth

[alt_names]
DNS.1 = $SERVICE
DNS.2 = localhost
EOF

  openssl req -new -key $SERVICE.key -out $SERVICE.csr -config $SERVICE.cnf

  # Sertifikayı imzala
  openssl x509 -req -in $SERVICE.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out $SERVICE.crt -days 365 -sha256 -extfile $SERVICE.cnf -extensions v3_req
  
  # Sertifika zinciri oluştur
  cat $SERVICE.crt ca.crt > $SERVICE-chain.crt
  
  # Temizlik
  rm $SERVICE.csr $SERVICE.cnf
done

# CA config dosyasını sil
rm ca.cnf

echo "✅ Tüm sertifikalar 'certs' klasöründe oluşturuldu:"
ls -l