{ config, pkgs, lib, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s;
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--disable=traefik"
      "--disable=servicelb"
      "--node-ip=192.168.1.10"
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
}