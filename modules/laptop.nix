{ config, pkgs, lib, ... }:
{
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

  # Disable systemd sleep services
  systemd.services = {
    "systemd-suspend".enable = false;
    "systemd-hibernate".enable = false;
    "systemd-hybrid-sleep".enable = false;
  };

  # Additional kernel parameters to prevent sleep
  boot.kernelParams = [
    "acpi=noirq"
    "acpi_osi=Linux"
    "acpi_force=1"
  ];
}
