#!/bin/bash

set -euo pipefail

# This script manages an etcd cluster by connecting to a control plane node.
# It can list and remove etcd members.

usage() {
    echo "Usage: $0 [-u user] [-p password] [-y] [-h] <control-plane-ip> <action> [action-args]"
    echo ""
    echo "Actions:"
    echo "  list              List members of the etcd cluster."
    echo "  remove <member-id> Remove a member from the etcd cluster."
    echo ""
    echo "If -u and -p are not provided, the script will attempt to use 'op' CLI for credentials."
    echo ""
    echo "Example:"
    echo "  $0 -u myuser -p mypassword 192.168.1.100"
    echo "  $0 -u myuser -p mypassword 192.168.1.100 remove 8e9e05c52164694d"
    echo "  $0 192.168.1.100 list"
    exit 1
}

CP_USER=""
CP_PASSWORD=""
CONFIRM="n"

while getopts "u:p:yh" opt; do
  case ${opt} in
    u )
      CP_USER=$OPTARG
      ;;
    p )
      CP_PASSWORD=$OPTARG
      ;;
    y )
      CONFIRM="y"
      ;;
    h)
      usage
      ;;
    * )
      echo "Invalid option: -$OPTARG" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

CP_IP="${1:-}"
ACTION="${2:-}"

ETCDCTL_COMMAND="sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt --cert=/var/lib/rancher/rke2/server/tls/etcd/server-client.crt --key=/var/lib/rancher/rke2/server/tls/etcd/server-client.key"

declare -a deps=("sshpass")

# Check for sshpass dependency
check_for_dep() {
  if ! command -v "$1" &> /dev/null; then
      echo "Error: $1 is not installed. Please install it to use this script"
      exit 1
  fi
}

run_remote_command() {
    local cmd="$1"
    # The -o options are to avoid host key checking prompts, which is useful for automation
    # but has security implications.
    sshpass -p "$CP_PASSWORD" ssh -o Ciphers='aes256-ctr,aes192-ctr,aes128-ctr' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${CP_USER}@${CP_IP}" "$cmd"
}

# If -u and -p are not provided, attempt to use op CLI.
if [ -z "${CP_USER}" ] && [ -z "${CP_PASSWORD}" ]; then
  if ! command -v "op" &> /dev/null; then
    echo "Error: credentials not provided via -u/-p flags and 'op' CLI not found."
    usage
  else
    echo "Info: -u and -p not provided. Attempting to use 'op' CLI for credentials."
    CP_USER=$(op read op://hncd/"SIL node persistent user"/username)
    CP_PASSWORD=$(op read op://hncd/"SIL node persistent user"/password)
  fi
elif [ -z "${CP_USER}" ] || [ -z "${CP_PASSWORD}" ]; then
    echo "Error: Both -u (username) and -p (password) must be provided together."
    usage
fi

for dep in "${deps[@]}"; do
  check_for_dep "$dep"
done

if [ -z "${CP_IP}" ] || [ -z "${CP_USER}" ] || [ -z "${CP_PASSWORD}" ] || [ -z "${ACTION}" ] ; then
    usage
fi

case "$ACTION" in
    list)
        echo "Listing etcd cluster members..."
        REMOTE_CMD="$ETCDCTL_COMMAND member list -w table"
        run_remote_command "$REMOTE_CMD"
        ;;
    remove)
        MEMBER_ID="${3:-}"
        if [ -z "${MEMBER_ID}" ]; then
            echo "Error: 'remove' action requires a member-id."
            usage
        fi
        if [ "${CONFIRM}" != "y" ]; then
          read -r -p "Are you sure you want to remove etcd member ${MEMBER_ID} [y/n]? (set -y to skip): " CONFIRM
        fi

        if [ "${CONFIRM}" = "y" ]; then
          echo "Removing etcd member ${MEMBER_ID}..."
          REMOTE_CMD="$ETCDCTL_COMMAND member remove ${MEMBER_ID}"
          run_remote_command "$REMOTE_CMD"
          echo "Member ${MEMBER_ID} removed. You may need to also remove the node from the cluster."
        else
          echo "Operation cancelled."
        fi
        ;;
    *)
        echo "Error: Unknown action '$ACTION'"
        usage
        ;;
esac
