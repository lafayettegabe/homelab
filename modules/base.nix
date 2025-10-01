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
  boot.kernelModules = [ "br_netfilter" "overlay" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "nf_conntrack" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "vm.swappiness" = 10;
  };

  # DNS configuration
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.resolvconf.dnsExtensionMechanism = false;

  # Firewall configuration for K3s
  networking.firewall.allowedTCPPorts = [ 6443 2379 2380 8472 10250 51820 51821 5001 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];
  networking.firewall.trustedInterfaces = [ "cni0" "flannel.1" ];
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.1.0/24 -m udp --dport 8472 -j nixos-fw-accept
  '';

  # Auto-upgrade configuration
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };
}
