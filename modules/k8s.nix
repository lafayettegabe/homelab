{ config, pkgs, lib, ... }:
{
  # Try MicroK8s instead of K3s
  services.microk8s = {
    enable = true;
    addons = [ "dns" "storage" "metrics-server" ];
  };

  # Configure containerd for MicroK8s
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
    KUBECONFIG = "/var/snap/microk8s/current/credentials/client.config";
  };

  environment.shellInit = ''
    export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config
  '';

  environment.shellAliases = {
    k = "kubectl";
  };
}
