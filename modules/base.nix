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
    cpuFreqGovernor = "ondemand";
    cpufreq.max = 3000000;
  };

environment.systemPackages = with pkgs; [
  git htop btop iotop iftop jq curl wget vim
  tmux neovim
  kubectl k9s
  iptables
  cni-plugins
  helm
  gnutar
  ser2net
  par2cmdline
  hdparm
  rsync
  gzip
  findutils
  libvirt
  qemu_full
  fluxcd
  coreutils
  memtest86plus
];

boot.kernelModules = [ "br_netfilter" "overlay" "ip_vs" "ip_vs_rr" "ip_vs_wrr" "ip_vs_sh" "nf_conntrack" ];
boot.kernel.sysctl = {
  "net.ipv4.ip_forward" = 1;
  "net.bridge.bridge-nf-call-iptables" = 1;
  "net.bridge.bridge-nf-call-ip6tables" = 1;
  "vm.swappiness" = 10;
  "net.ipv4.conf.all.forwarding" = 1;
  "net.ipv6.conf.all.forwarding" = 1;
};

  networking.nameservers = [ "1.1.1.1" ];
  networking.resolvconf.dnsExtensionMechanism = false;

networking.firewall = {
  enable = true;
  checkReversePath = false;
  allowedTCPPorts = [ 6443 80 443 10250 8080 8181 ];
  allowedUDPPorts = [ 8472 ];
  trustedInterfaces = [ "cni0" "flannel.1" "veth+" ];
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

  boot.loader.grub = {
    extraEntries = ''
      menuentry "Memtest86+" {
        linux /@/boot/memtest.bin console=ttyS0,115200
      }
    '';
    extraFiles."../memtest.bin" = "${pkgs.memtest86plus}/memtest.bin";
  };
}
