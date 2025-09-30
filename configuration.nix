{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hosts/server_1.nix
    ./modules/base.nix
    ./modules/ssh.nix
    ./modules/k3s-single.nix
    ./modules/laptop.nix
    ./modules/sensors.nix
    ./modules/tmux.nix
  ];
}
