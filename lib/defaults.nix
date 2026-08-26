# ---------------------------------------------------------------------------
# Baseline applied to every host in this flake.
# Everything here is deliberately boring: bootloader, desktop, audio, input,
# the user account, and a small system package set.
# ---------------------------------------------------------------------------
{ config, pkgs, ... }: {
  # --- Nix: flakes & automatic garbage collection --------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;

  # --- Boot -----------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Networking ------------------------------------------------------------
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];   # SSH. Add ports here as services need them.
  };

  # --- Locale / time (change to your own!) ----------------------------------
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

  # --- Desktop: Plasma 6 on X11 ---------------------------------------------
  # I run X11 rather than Wayland on purpose: a couple of the remote-desktop
  # and capture tools I use work far more reliably under X11. If you don't
  # need them, flip these two to the wlroots/KWin-Wayland variants or just
  # keep Plasma on X11 — it's still perfectly good.
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # --- Hardware ---------------------------------------------------------------
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;   # 32-bit DRI libs: cheap insurance
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Audio & media ------------------------------------------------------------
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;    # pulse compatibility for apps that still ask
  };

  # --- Misc ----------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;      # unlocks Brave & a few others; drop if unwanted
  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  # --- The user account (change the key + description to your name) ----------
  users.users."user" = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" ];   # wheel = sudo
  };

  # --- System-wide packages -----------------------------------------------------
  environment.systemPackages = with pkgs; [
    rsync
    nfs-utils        # if you mount NFS shares
    ripgrep
    vim
  ];
}
