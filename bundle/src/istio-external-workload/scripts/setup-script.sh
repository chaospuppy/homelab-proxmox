#!/bin/bash

#istioctl x workload entry configure --name fleeting-runners --namespace istio-external-workloads -o ./external-workload-registration --clusterID "Kubernetes" --autoregister --ingressIP 192.168.2.21

WORKLOAD_RESOURCES_DIR=${1:-"."}
ISTIO_CERTS_DIR="/etc/certs"
TOKEN_DIR="/var/run/secrets/tokens"
ISTIO_SIDECAR_VERSION="1.29.0"

dirs=("$ISTIO_CERTS_DIR" "$TOKEN_DIR")

for dir in "${dirs[@]}"; do
  sudo mkdir -p "$dir"
done

sudo cp "$WORKLOAD_RESOURCES_DIR/root-cert.pem" "$ISTIO_CERTS_DIR"
sudo cp "$WORKLOAD_RESOURCES_DIR/istio-token" "$TOKEN_DIR"

# TODO: just preinstall
curl -LO "https://storage.googleapis.com/istio-release/releases/$ISTIO_SIDECAR_VERSION/deb/istio-sidecar.deb"
sudo dpkg -i istio-sidecar.deb

sudo cp "${WORKLOAD_RESOURCES_DIR}"/cluster.env /var/lib/istio/envoy/cluster.env
sudo cp "${WORKLOAD_RESOURCES_DIR}"/mesh.yaml /etc/istio/config/mesh
cat "${WORKLOAD_RESOURCES_DIR}/hosts" | sudo tee -a /etc/hosts

sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets

sudo systemctl start istio
