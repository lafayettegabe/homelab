{ config, pkgs, lib, ... }:
let
  domain = "homelab";
  ip = "192.168.1.2";
in
{
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s;
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
          ${domain}:53 {
            errors
            health
            ready
            hosts {
              ${ip} ${domain}
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

  environment.etc."k3s/helmfile.yaml" = {
    mode = "0750";
    text = ''
      repositories:
        - name: coredns
          url: https://coredns.github.io/helm
        - name: cilium
          url: https://helm.cilium.io
      releases:
        - name: cilium
          namespace: kube-system
          chart: cilium/cilium
          version: 1.17.4
          values:
            - kubeProxyReplacement: "disabled"
            - ipam:
                mode: "kubernetes"
            - k8sServiceHost: "127.0.0.1"
            - k8sServicePort: "6443"
            - cluster:
                name: "homelab"
            - operator:
                replicas: 1
          wait: true
        - name: coredns
          namespace: kube-system
          chart: coredns/coredns
          version: 1.42.4
          values:
            - service:
                clusterIP: "10.43.0.10"
            - config:
                custom:
                  homelab:53 {
                    errors
                    health
                    ready
                    hosts {
                      ${ip} ${domain}
                      fallthrough
                    }
                    prometheus :9153
                    forward . /etc/resolv.conf
                    cache 30
                    loop
                    reload
                    loadbalance
                  }
          wait: true
          needs:
          - kube-system/cilium
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/rancher/k3s/server/manifests 0755 root root -"
    "L /var/lib/rancher/k3s/server/manifests/00-coredns-custom.yaml - - - - /etc/k3s/coredns-custom.yaml"
    "L /var/lib/rancher/k3s/server/manifests/01-helmfile.yaml - - - - /etc/k3s/helmfile.yaml"
  ];

  systemd.services.k3s-helmfile = {
    wantedBy = [ "multi-user.target" ];
    after = [ "k3s.service" ];
    requires = [ "k3s.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "DISPLAY=";
      ExecStart = pkgs.writeShellScript "k3s-helmfile" ''
        set -e
        unset DISPLAY
        export DISPLAY=""
        echo "Waiting for K3s to be ready..."
        until ${pkgs.kubectl}/bin/kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes >/dev/null 2>&1; do
          sleep 5
        done
        echo "K3s is ready, deploying helmfile..."
        ${pkgs.helm}/bin/helm repo add coredns https://coredns.github.io/helm
        ${pkgs.helm}/bin/helm repo add cilium https://helm.cilium.io
        ${pkgs.helm}/bin/helm repo update
        ${pkgs.helm}/bin/helm upgrade --install cilium cilium/cilium --version 1.17.4 \
          --namespace kube-system \
          --set kubeProxyReplacement=disabled \
          --set ipam.mode=kubernetes \
          --set k8sServiceHost=127.0.0.1 \
          --set k8sServicePort=6443 \
          --set cluster.name=homelab \
          --set operator.replicas=1 \
          --wait
        ${pkgs.helm}/bin/helm upgrade --install coredns coredns/coredns --version 1.42.4 \
          --namespace kube-system \
          --set service.clusterIP=10.43.0.10 \
          --wait
        echo "Helmfile deployment completed"
      '';
    };
  };
}
