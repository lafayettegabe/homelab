{ config, pkgs, lib, ... }:
{
  # Temperature monitoring with lm_sensors
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # Kernel modules for sensor detection
  boot.kernelModules = [ 
    "coretemp"
    "k10temp" 
    "nct6775"
  ];
}
