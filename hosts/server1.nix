{ config, pkgs, lib, ... }:
{
  networking.hostName = "homelab";
  networking.useDHCP = lib.mkDefault true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6443 10250 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];
}
