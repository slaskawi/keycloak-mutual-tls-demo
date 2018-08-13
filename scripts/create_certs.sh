#!/bin/bash

echo "Nice link: http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art042"

echo "==== Removing old files ===="
find . -name "*.jks" -exec rm -rf {} \;
find . -name "*.crt" -exec rm -rf {} \;
find . -name "*.pem" -exec rm -rf {} \;
find . -name "*.p12" -exec rm -rf {} \;
find . -name "*.pfx" -exec rm -rf {} \;


echo "==== Generating private keys ===="
keytool -genkey -noprompt -trustcacerts -keyalg RSA -alias "main" -dname "CN=localhost, OU=Keycloak, O=JBoss, L=Red Hat, ST=World, C=WW" -keypass "secret" -storepass "secret" -keystore "server-keystore.jks"
keytool -genkey -noprompt -trustcacerts -keyalg RSA -alias "main" -dname "CN=localhost, OU=Keycloak, O=JBoss, L=Red Hat, ST=World, C=WW" -keypass "secret" -storepass "secret" -keystore "client-keystore.jks"

echo "==== Generating certificates ===="
keytool -export -keyalg RSA -alias "main" -storepass "secret" -file "server-cert.cer" -keystore "server-keystore.jks"
keytool -exportcert -rfc -alias "main" -storepass "secret" -keystore "server-keystore.jks" > server-cert.pem
keytool -importkeystore -srckeystore "server-keystore.jks" -destkeystore "server-keystore.pfx" -deststoretype PKCS12 -srcalias main -deststorepass secret -destkeypass secret -srcstorepass secret -srckeypass secret
openssl pkcs12 -in "server-keystore.pfx" -out "server-keystore.p12" -nodes -passin pass:secret

keytool -export -keyalg RSA -alias "main" -storepass "secret" -file "client-cert.cer" -keystore "client-keystore.jks"
keytool -exportcert -rfc -alias "main" -storepass "secret" -keystore "client-keystore.jks" > client-cert.pem
keytool -importkeystore -srckeystore "client-keystore.jks" -destkeystore "client-keystore.pfx" -deststoretype PKCS12 -srcalias main -deststorepass secret -destkeypass secret -srcstorepass secret -srckeypass secret
openssl pkcs12 -in "client-keystore.pfx" -out "client-keystore.p12" -nodes -passin pass:secret

echo "==== Importing certificates ===="
keytool -import -noprompt -v -trustcacerts -keyalg RSA -alias "main" -file "client-cert.cer" -keypass "secret" -storepass "secret" -keystore "server-truststore.jks"
keytool -import -noprompt -v -trustcacerts -keyalg RSA -alias "main" -file "server-cert.cer" -keypass "secret" -storepass "secret" -keystore "client-truststore.jks"

