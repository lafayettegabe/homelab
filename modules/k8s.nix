{ config, pkgs, lib, ... }:
{
  # Try K3s with minimal configuration and different approach
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable=metrics-server"
      "--disable=local-storage"
      "--disable-network-policy"
      "--cluster-init"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
      "--flannel-backend=host-gw"
    ];
  };

  # Use external containerd
  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri".containerd = {
        snapshotter = "overlayfs";
      };
    };
  };

  # Critical: Delegate cgroups for proper container networking
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  environment.variables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  environment.shellInit = ''
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  '';

  environment.shellAliases = {
    k = "kubectl";
  };
}
