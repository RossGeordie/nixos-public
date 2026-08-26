# Shared baseline for Ross's NixOS machines.
{ config, pkgs, ... }: {
  # --- Flakes/nix-command on the system side too ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;

  # --- Boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Networking ---
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 2049 9800 9802 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };

  # --- Locale / time ---
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "uk";
  services.xserver.xkb = { layout = "gb"; };

  # --- Desktop (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- Hardware baseline ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # 32-bit graphics/DRI (Mesa) for the X360 Intel GPU
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # --- Audio / input / printing ---
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Misc ---
  nixpkgs.config.allowUnfree = true;
  services.openssh.enable = true;

  # --- The user account (shared by all our hosts) ---
  users.users."user" = {
    isNormalUser = true;
    description = "Ross";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # --- System-level packages (shared baseline) ---
  environment.systemPackages = with pkgs; [
    nfs-utils
    libnfs
    rsync
    libreoffice-qt
    vscode
    mangohud
    protonup-ng
  ];
}
