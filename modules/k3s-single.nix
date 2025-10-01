{ config, pkgs, lib, ... }:
{
  # Configure containerd for K3s
  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri".containerd = {
        snapshotter = "overlayfs";
      };
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable=metrics-server"
      "--flannel-iface=enp3s0"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
    ];
  };

  # Add systemd service dependencies for proper networking
  systemd.services.k3s = {
    after = [ "network-online.target" "containerd.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
  };

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
