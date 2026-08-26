# Home Manager config for the "user" account, activated by the system build.
{ pkgs, ... }: {
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "26.05";

  # Silence the (false-positive) HM/nixpkgs version-pairing nag; the flake pins
  # release-matched versions (HM release-26.05 + nixos-26.05) anyway.
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    git-credential-manager
    ripgrep
    fd
    jq
  ];

  programs.zsh.enable = true;   # switch later with `chsh -s`
}
