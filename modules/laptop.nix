{ config, pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    settings = {
      Login = {
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
    };
  };

  systemd.sleep.settings = {
    Sleep = {
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };
  };

  systemd.services = {
    "systemd-suspend".enable = false;
    "systemd-hibernate".enable = false;
    "systemd-hybrid-sleep".enable = false;
  };

  boot.kernelParams = [
    "video=eDP-1:d"
    "amd_pstate=active"
    "acpi=noirq"
    "acpi_osi=Linux"
    "acpi_force=1"
    "nouveau.modeset=0"
    "nvidia.modeset=0"
  ];

  boot.blacklistedKernelModules = [ 
    "nvidia" 
    "nvidia_drm" 
    "nvidia_modeset" 
    "nouveau" 
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
    powertop.enable = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_MIN_FREQ_ON_AC = 0;
      CPU_SCALING_MAX_FREQ_ON_AC = 0;
      CPU_SCALING_MIN_FREQ_ON_BAT = 0;
      CPU_SCALING_MAX_FREQ_ON_BAT = 0;
    };
  };
}