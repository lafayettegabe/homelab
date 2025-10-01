{ config, pkgs, ... }:
{
  system.stateVersion = "25.05";

  imports = [
    ./hardware-configuration.nix
    ./hosts/server1.nix
    ./modules/base.nix
    ./modules/ssh.nix
    ./modules/k8s.nix
    ./modules/laptop.nix
    ./modules/sensors.nix
    ./modules/tmux.nix
  ];
}
