#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Script must be run as root"
  exit 1
fi

if [ $# -eq 0 ]; then
  exit 1
fi

while getopts "as" o; do
  case "${o}" in
    a) agent=1 ;;
    s) server=1 ;;
    *) exit 1 ;;
  esac
done

# Ensure file permissions match STIG rules - https://www.stigviewer.com/stig/rancher_government_solutions_rke2/2022-10-13/finding/V-254564
echo "Fixing RKE2 file permissions for STIG"
dir=/etc/rancher/rke2
chmod -R 0600 $dir/*
chown -R root:root $dir/*

dir=/var/lib/rancher/rke2
chown root:root $dir/*

dir=/var/lib/rancher/rke2/agent
chown root:root $dir/*
chmod 0700 $dir/pod-manifests
chmod 0700 $dir/etc
find $dir -maxdepth 1 -type f -name "*.kubeconfig" -exec chmod 0600 {} \;
find $dir -maxdepth 1 -type f -name "*.crt" -exec chmod 0600 {} \;
find $dir -maxdepth 1 -type f -name "*.key" -exec chmod 0600 {} \;

dir=/var/lib/rancher/rke2/bin
chown root:root $dir/*
chmod 0750 $dir/*

dir=/var/lib/rancher/rke2/data
chown root:root $dir
chmod 0750 $dir
chown root:root $dir/*
chmod 0640 $dir/*

# Skip these if not running as a server
if [ -z $agent ]; then
  dir=/var/lib/rancher/rke2/server
  chown root:root $dir/*
  chmod 0700 $dir/cred
  chmod 0700 $dir/db
  chmod 0700 $dir/tls
  chmod 0750 $dir/manifests
  chmod 0750 $dir/logs
  chmod 0600 $dir/token
fi
