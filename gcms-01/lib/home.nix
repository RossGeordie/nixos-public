# Home Manager config for user 'user' on gcms-01 (Minisforum MS-01).
# Placeholder for the flake flip — full home-manager config lands later.
{ config, pkgs, lib, ... }: {
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    git        # gcms-01 currently has no git — add via home for convenience
    htop
  ];
}
