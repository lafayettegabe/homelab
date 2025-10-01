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
  tmux neovim
  kubectl k9s
  iptables
  cni-plugins
];

  boot.kernelModules = [ "br_netfilter" "overlay" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "vm.swappiness" = 10;
  };

  networking.nameservers = [ "1.1.1.1" ];
  networking.resolvconf.dnsExtensionMechanism = false;

networking.firewall.enable = true;
networking.firewall.allowedTCPPorts = [ 6443 80 443 10250 ];
networking.firewall.allowedUDPPorts = [ 8472 ];

  networking.useNetworkd = true;
  systemd.network.enable = true;
  
  systemd.network.networks."40-enp3s0" = {
    matchConfig.Name = "enp3s0";
    networkConfig.DHCP = "yes";
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };
}
