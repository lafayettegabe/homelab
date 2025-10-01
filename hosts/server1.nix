{ config, pkgs, lib, ... }:
{
  networking.hostName = "homelab";
  networking.useDHCP = lib.mkDefault true;

  # Firewall configuration moved to base.nix
}
