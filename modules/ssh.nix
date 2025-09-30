{ config, pkgs, lib, ... }:
let authorizedKeys = builtins.readFile ../secrets/homelab_authorized_keys.pub;
in {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.server1 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ authorizedKeys ];
  };

  security.sudo.wheelNeedsPassword = false;
}
