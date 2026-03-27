#!/bin/bash

#istioctl x workload entry configure --name fleeting-runners --namespace fleeting-runners -o ./external-workload-registration --clusterID "Kubernetes" --autoregister --ingressIP 192.168.2.21

ISTIO_CERTS_DIR="/etc/certs"
TOKEN_DIR="/var/run/secrets/tokens"

WORKLOAD_RESOURCES_DIR=${1:-"."}

sudo mkdir -p "$TOKEN_DIR"

sudo cp "$WORKLOAD_RESOURCES_DIR/root-cert.pem" "$ISTIO_CERTS_DIR"
sudo cp "$WORKLOAD_RESOURCES_DIR/istio-token" "$TOKEN_DIR"
sudo cp "${WORKLOAD_RESOURCES_DIR}"/cluster.env /var/lib/istio/envoy/cluster.env
sudo cp "${WORKLOAD_RESOURCES_DIR}"/mesh.yaml /etc/istio/config/mesh
cat "${WORKLOAD_RESOURCES_DIR}/hosts" | sudo tee -a /etc/hosts

sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets

sudo systemctl start istio
