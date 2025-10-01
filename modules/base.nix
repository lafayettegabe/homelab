{ config, pkgs, lib, ... }:
{
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  services.journald.extraConfig = "SystemMaxUse=500M";
  
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    cpufreq.max = 3000000;
  };

environment.systemPackages = with pkgs; [
  git htop btop iotop iftop jq curl wget vim
  tmux neovim
  kubectl k9s
  helm
  iptables
  gnutar
  hdparm
  rsync
  gzip
  findutils
  coreutils
];

boot.kernelModules = [ "br_netfilter" "overlay" ];
boot.kernel.sysctl = {
  "vm.swappiness" = 10;
};

  networking.nameservers = [ "1.1.1.1" ];
  networking.resolvconf.dnsExtensionMechanism = false;

networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 6443 80 443 10250 ];
  allowedUDPPorts = [ 8472 ];
};

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

  services.udev.extraRules = 
    let
      mkRule = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in mkRules ([( mkRule [
      ''ACTION=="add|change"''
      ''SUBSYSTEM=="block"''
      ''KERNEL=="sd[a-z]"''
      ''ATTR{queue/rotational}=="1"''
      ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 60 /dev/%k"''
    ])]);

}
