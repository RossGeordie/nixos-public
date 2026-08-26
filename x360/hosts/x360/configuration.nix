{ pkgs, ... }: {
  imports = [
    ../../lib/mods/defaults.nix
    ../../lib/mods/pkgs.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "rx360";

  # Phase 1: user packages stay in the system config (behaviour-preserving).
  # Phase 2 (documented): move into lib/home.nix and remove from here.
  users.users."user".packages = with pkgs; [
    kdePackages.kate
    thunderbird
    brave
    btop
    keepass
    heroic
    telegram-desktop
    vlc
    obsidian    # 2026-08-24: requested via Telegram; markdown/wiki reader (Electron)
  ];
}
