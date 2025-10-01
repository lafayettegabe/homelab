{ config, pkgs, lib, ... }:
{
  # Use full Kubernetes with kubeadm instead of K3s
  services.kubernetes = {
    master = {
      enable = true;
      apiserver = {
        advertiseAddress = "192.168.1.2";
        bindAddress = "0.0.0.0";
        extraOpts = "--service-cluster-ip-range=10.43.0.0/16";
      };
      etcd = {
        enable = true;
        extraOpts = {
          listen-client-urls = "https://127.0.0.1:2379,https://192.168.1.2:2379";
          listen-peer-urls = "https://192.168.1.2:2380";
          initial-cluster = "homelab=https://192.168.1.2:2380";
          initial-cluster-state = "new";
          initial-cluster-token = "k8s-cluster-token";
          data-dir = "/var/lib/etcd";
        };
      };
    };
    worker = {
      enable = true;
      kubelet = {
        extraOpts = "--pod-cidr=10.42.0.0/16";
      };
    };
    flannel = {
      enable = true;
      network = "10.42.0.0/16";
    };
    addons.dns = {
      enable = true;
    };
    addons.dashboard = {
      enable = true;
    };
  };

  # Configure containerd for Kubernetes
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
    KUBECONFIG = "/etc/kubernetes/admin.conf";
  };

  environment.shellInit = ''
    export KUBECONFIG=/etc/kubernetes/admin.conf
  '';

  environment.shellAliases = {
    k = "kubectl";
  };
}
