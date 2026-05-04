#!/bin/bash
# 创建自签名证书用于代码签名

# 1. 创建证书请求配置文件
cat > cert.conf << 'CONF'
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = US
ST = California
L = San Francisco
O = Development
CN = "Mac Developer: Local Signing"
CONF

[v3_req]
basicConstraints = CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = codeSigning
CONF

# 2. 生成私钥和证书
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3650 -nodes -config cert.conf

# 3. 创建 PKCS12 文件
openssl pkcs12 -export -out certificate.p12 -inkey key.pem -in cert.pem -password pass:RustDesk123

# 4. 添加到钥匙串并设置为始终信任
security import cert.pem -k ~/Library/Keychains/login.keychain-db -A -T /usr/bin/codesign 2>/dev/null
security import key.pem -k ~/Library/Keychains/login.keychain-db -A -T /usr/bin/codesign 2>/dev/null
security import certificate.p12 -k ~/Library/Keychains/login.keychain-db -P RustDesk123 -T /usr/bin/codesign 2>/dev/null

# 5. 设置证书为始终信任
/usr/bin/security unlock-keychain -p "" ~/Library/Keychains/login.keychain-db 2>/dev/null

echo "证书创建完成"
openssl x509 -in cert.pem -noout -subject -issuer
