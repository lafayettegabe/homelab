{ config, pkgs, lib, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable=metrics-server"
      "--disable=local-storage"
      "--disable=coredns"
      "--disable=flannel"
      "--cluster-init"
    ];
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

  environment.etc."k3s/coredns-custom.yaml" = {
    mode = "0750";
    text = ''
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: coredns-custom
        namespace: kube-system
      data:
        domain.server: |
          homelab:53 {
            errors
            health
            ready
            hosts {
              192.168.1.2 homelab
              fallthrough
            }
            prometheus :9153
            forward . /etc/resolv.conf
            cache 30
            loop
            reload
            loadbalance
          }
    '';
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/rancher/k3s/server/manifests/00-coredns-custom.yaml - - - - /etc/k3s/coredns-custom.yaml"
  ];
}
