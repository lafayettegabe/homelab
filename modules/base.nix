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
  ];

  boot.kernelModules = [ "br_netfilter" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "vm.swappiness" = 10;
  };

  # Additional kernel parameters to prevent sleep
  boot.kernelParams = [
    "acpi=noirq"
    "acpi_osi=Linux"
    "acpi_force=1"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:30";
  };

  # Laptop-specific settings - prevent sleep when lid is closed
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
    '';
  };

  # Disable power management that could cause sleep
  powerManagement = {
    enable = false;  # Disable power management entirely
  };

  # Additional sleep prevention
  systemd.sleep.extraConfig = ''
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  # Disable suspend/hibernate targets
  systemd.targets = {
    sleep.target.enable = false;
    suspend.target.enable = false;
    hibernate.target.enable = false;
    hybrid-sleep.target.enable = false;
  };
}
