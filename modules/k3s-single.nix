{ config, pkgs, lib, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    serverArgs = [
      "--write-kubeconfig-mode=0644"
      "--disable traefik"
      "--flannel-backend=vxlan"
    ];
  };
}
