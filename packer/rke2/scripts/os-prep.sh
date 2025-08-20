#!/bin/bash
set -e

# sysctl changes for UDS Core apps - (originally from https://docs-bigbang.dso.mil/latest/docs/prerequisites/os-preconfiguration/)
declare -A sysctl_settings
sysctl_settings["fs.nr_open"]=13181250
sysctl_settings["fs.inotify.max_user_instances"]=1024
sysctl_settings["fs.inotify.max_user_watches"]=1048576

# sysctl changes for UDS SWF apps
# GitLab Runner (Buildah) (note - this is a STIG finding but is n/a when running Linux containers: https://www.stigviewer.com/stig/red_hat_enterprise_linux_9/2023-09-13/finding/V-257816)
sysctl_settings["user.max_user_namespaces"]=30110

# SonarQube
sysctl_settings["vm.max_map_count"]=524288
sysctl_settings["fs.file-max"]=13181250

for key in "${!sysctl_settings[@]}"; do
  value="${sysctl_settings[$key]}"
  sysctl -w "$key=$value"
  echo "$key=$value" >"/etc/sysctl.d/$key.conf"
done
sysctl -p

# Kernel Modules for Istio -https://istio.io/latest/docs/ops/deployment/platform-requirements/
modules=("br_netfilter" "xt_REDIRECT" "xt_owner" "xt_statistic" "iptable_mangle" "iptable_nat" "xt_conntrack" "xt_tcpudp")
for module in "${modules[@]}"; do
  modprobe "$module"
  echo "$module" >>"/etc/modules-load.d/istio-modules.conf"
done

# cgroupsv2 for RKE2 + NeuVector
sed -i 's/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"systemd.unified_cgroup_hierarchy=1 /' /etc/default/grub
update-grub

# If Network Manager is being used configure it to ignore calico/flannel network interfaces - https://docs.rke2.io/known_issues#networkmanager
if systemctl list-units --full | grep -Poi "NetworkManager.service" &>/dev/null; then
  # Indent with tabs to prevent spaces in heredoc output
  cat <<-EOF >/etc/NetworkManager/conf.d/rke2-canal.conf
	[keyfile]
	unmanaged-devices=interface-name:cali*;interface-name:flannel*
	EOF
  systemctl reload NetworkManager
fi

# If present, disable services that interfere with cluster networking - https://docs.rke2.io/known_issues#firewalld-conflicts-with-default-networking
services_to_disable=("firewalld" "nm-cloud-setup" "nm-cloud-setup.timer")
for service in "${services_to_disable[@]}"; do
  if systemctl list-units --full -all | grep -Poi "$service.service" &>/dev/null; then
    systemctl stop "$service.service"
    systemctl disable "$service.service"
  fi
done
