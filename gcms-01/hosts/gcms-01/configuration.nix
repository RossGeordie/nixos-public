{ config, pkgs, ... }: {

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable flakes/nix-command so `nixos-rebuild --flake` works after this switch.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gcms-01";
  networking.networkmanager.enable = true;

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

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # ---------------------------------------------------------------------------
  # Hardware: Minisforum MS-01 — i9-13900H (14C/20T), Intel Raptor Lake iGPU
  # (PCI 0x8086:0xa720), 32 GB RAM, 3x NVMe, KVM, MT7921e WiFi (mac80211),
  # UEFI + systemd-boot.
  # iGPU uses the built-in i915/Xe drivers (no external video driver needed);
  # enabling graphics pulls in the right module set for the modesetting path.
  # ---------------------------------------------------------------------------
  hardware.graphics.enable = true;
  # 6.6+ kernel ships mt7921e/mac80211 built in — no extra module packages.
  # hardware.cpu.intel.updateMicrocode is already default-on via hardware-config.

  # Plasma 6 on X11: RustDesk 1.4.x GTK capturer needs X11 (Wayland capture fails).
  services.desktopManager.plasma6.enable = true;

  # SDDM autologin => a live Plasma session is always running after boot.
  # That is the session RustDesk mirrors when you connect remotely.
  # Pinned to the X11 variant (plasma-x11): RustDesk 1.4.x GTK screen capture
  # is unreliable/unsupported on Wayland.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.settings = {
    Autologin = {
      User = "user";
      Session = "plasma-x11";
    };
  };
  # Autologin is unattended — let the session stay active so RustDesk has a
  # live screen to mirror. (Bl/sleep left at distribution defaults.)

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.user = {
    isNormalUser = true;
    description = "Ross";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      telegram-desktop
    ];
  };

  # Set default browser: Brave
  system.activationScripts.defaultBrowser = ''
    mkdir -p /etc/xdg
    cat > /etc/xdg/mimeapps.list << 'EOF'
[Default Applications]
x-scheme-handler/http=brave.desktop
x-scheme-handler/https=brave.desktop
text/html=brave.desktop
EOF
  '';

  environment.systemPackages = with pkgs; [
    brave
    telegram-desktop
    rustdesk
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
  # RustDesk: 21116 (TCP relay fallback) + 21117 (direct P2P) inbound.
  networking.firewall.allowedTCPPortRanges = [
    { from = 21116; to = 21117; }
  ];

  # Allow unfree packages (Brave is unfree; rustdesk depends on unfree libsciter).
  nixpkgs.config.allowUnfree = true;

  # Disable Firefox if no longer needed
  programs.firefox.enable = false;

  # ---------------------------------------------------------------------------
  # nas (UniFi NAS / nas == 192.0.2.241)
  # Same export the laptop mounts at /mnt/nas. NFSv3 known-good for this
  # box (v4.2 statfs probes fail on the server), so pin vers=3.
  # ---------------------------------------------------------------------------
  fileSystems."/mnt/nas" = {
    device = "192.0.2.241:/volume/11111111-2222-3333-4444-555555555555/.srv/.unifi-drive/nas/.data";
    fsType = "nfs";
    options = [
      "noauto,noatime,hard,tcp,vers=3,timeo=600,rsize=1048576,wsize=1048576"
      "x-systemd.automount"
      "nofail"
    ];
  };

  # ---------------------------------------------------------------------------
  # RustDesk autostart — launched inside the autologin user session so GTK
  # attaches to the live X11 display (a root-level service can't grab the
  # display). ID + password are set ONCE from the GUI after first boot and
  # persist in /home/user/.config/rustdesk/.
  # ---------------------------------------------------------------------------
  system.activationScripts.rustdesk-autostart = ''
    mkdir -p /home/user/.config/autostart
    cat > /home/user/.config/autostart/org.rustdesk.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=RustDesk
Comment=RustDesk remote desktop (session autostart)
Exec=rustdesk --service
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
    chmod 644 /home/user/.config/autostart/org.rustdesk.desktop
    chown -R user:users /home/user/.config/autostart
  '';

  system.stateVersion = "26.05";
}
