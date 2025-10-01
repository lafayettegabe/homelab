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

  # Minimal kernel configuration (based on working k3s-nix example)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "vm.swappiness" = 10;
  };

  # DNS configuration
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.resolvconf.dnsExtensionMechanism = false;

  # Firewall configuration for K3s (with additional ports for pod networking)
  networking.firewall.allowedTCPPorts = [ 6443 80 443 10250 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  # Auto-upgrade configuration
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };
}
