{ config, pkgs, lib, ... }:
{
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  services.journald.extraConfig = "SystemMaxUse=500M";
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    git htop btop iotop iftop jq curl wget vim
    kubectl k9s
  ];

  boot.kernelModules = [ "br_netfilter" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "vm.swappiness" = 10;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };
}
