# Home Manager: the user user, activated by the NixOS system build.
{ pkgs, ... }: {
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "26.05";

  # Silence the (false-positive) HM/nixpkgs version-pairing nag; inputs are
  # release-matched via the flake (HM release-26.05 + nixos-26.05).
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    git-credential-manager
    ripgrep
    gnuradio
  ];

  programs.zsh.enable = true;    # activate login shell later: chsh -s zsh
}
