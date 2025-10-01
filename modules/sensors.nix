{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  boot.kernelModules = [ 
    "coretemp"
    "k10temp" 
    "nct6775"
  ];
}
