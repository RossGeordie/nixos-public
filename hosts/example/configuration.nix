{ config, pkgs, ... }: {
  imports = [
    ../../lib/defaults.nix
    ./hardware-configuration.nix   # produced by `sudo nixos-hw-sync`
  ];

  networking.hostName = "example";   # change me
  networking.wireless.iwd.enable = true;   # laptop WiFi; drop if desktop

  # Laptops: battery management. Asserts the two don't coexist — pick PPD.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Optional: a Steam/retro gaming block lives in the README instead of here,
  # so this starter stays lean.

  system.stateVersion = "26.05";
}
