#!/bin/bash

echo "Installing Istio..."

ISTIO_CERTS_DIR="/etc/certs"
TOKEN_DIR="/var/run/secrets/tokens"
ISTIO_SIDECAR_VERSION="1.29.0"

dirs=("$ISTIO_CERTS_DIR" "$TOKEN_DIR")

for dir in "${dirs[@]}"; do
  sudo mkdir -p "$dir"
done

curl -LO "https://storage.googleapis.com/istio-release/releases/$ISTIO_SIDECAR_VERSION/deb/istio-sidecar.deb"
sudo dpkg -i istio-sidecar.deb

sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets
