{ config, pkgs, lib, ... }:
{
  # Core system settings
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # System optimization
  services.journald.extraConfig = "SystemMaxUse=500M";
  zramSwap.enable = true;

  # Core system packages
  environment.systemPackages = with pkgs; [
    git htop btop iotop iftop jq curl wget vim
    tmux neovim
    kubectl k9s
  ];

  # Network and container kernel modules
  boot.kernelModules = [ "br_netfilter" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "vm.swappiness" = 10;
  };

  # DNS configuration
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Auto-upgrade configuration
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };
}
