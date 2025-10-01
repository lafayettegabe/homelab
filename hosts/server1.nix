{ config, pkgs, lib, ... }:
{
  networking.hostName = "homelab";
  # Remove DHCP conflict - let systemd-networkd handle networking
  # networking.useDHCP = lib.mkDefault true;

  # Firewall configuration moved to base.nix
}
