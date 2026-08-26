# x360 (HP Elite X360) host-specific extras: Intel graphics, battery, gaming, NAS mounts.
{ config, pkgs, ... }: {
  # --- Intel / X360 laptop specifics ---
  boot.kernelParams = [ "acpi_backlight=vendor" ];
  # Battery manager: the LIVE system runs power-profiles-daemon (verified
  # active, tlp inactive). NixOS asserts the two conflict -> PPD on, TLP off.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  # --- Gaming stack (this is the main daily-driver + Steam machine) ---
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    "/home/user/.steam/root/compatibilitytools.d";

  # --- NAS automount (UniFi 192.0.2.240, UDM) ---
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/nas" = {
    device  = "192.0.2.241:/volume/11111111-2222-3333-4444-555555555555/.srv/.unifi-drive/nas/.data";
    fsType  = "nfs";
    options = [ "noauto" "noatime" "hard" "tcp" "vers=3" "timeo=600" "x-systemd.automount" "nofail" "rsize=1048576" "wsize=1048576" ];
  };

  system.stateVersion = "26.05";
}
