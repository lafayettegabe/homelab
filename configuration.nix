{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hosts/server_1.nix
    ./modules/base.nix
    ./modules/ssh.nix
    ./modules/k3s-single.nix
  ];
}
