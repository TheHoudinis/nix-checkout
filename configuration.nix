# NixOS + Hyprland (UWSM) + Caelestia, greetd/tuigreet login.
# Browsers (zen, helium) come from flake.nix.

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep /boot from filling up
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ──────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true; # physical Wi-Fi firmware

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # managed through Caelestia Shell
  };

  # DDC/CI brightness control for external monitors.
  hardware.i2c.enable = true;

  # ── Locale / time / keyboard ────────────────────────────────────────
  time.timeZone = "Asia/Bishkek";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # English + Russian layouts, Alt+Shift to toggle.
  # xserver.enable is kept because the NVIDIA driver is wired through it.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:alt_shift_toggle";
  };

  # ── Desktop: Hyprland, no KDE/SDDM ──────────────────────────────────
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Login screen: greetd + tuigreet, launches Hyprland through UWSM.
  services.greetd = {
    enable = true;
    useTextGreeter = true; # stops boot messages garbling the TUI
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd 'uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };

  # Electron/Chromium apps (vesktop, helium) use native Wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ── Graphics (NVIDIA GTX 1660 Ti) ───────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam / Proton / Wine
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Turing (16xx) is supported by the open kernel module
    nvidiaSettings = true;
  };

  # ── Audio ───────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Services ────────────────────────────────────────────────────────
  services.printing.enable = true;
  services.flatpak.enable = true; # Sober is distributed through Flathub

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # ── User / shell ────────────────────────────────────────────────────
  programs.fish.enable = true;

  users.users."houdini" = {
    isNormalUser = true;
    description = "houdini";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  # ── Packages ────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only # glyphs used by the Fish prompt and shell UI
  ];

  environment.systemPackages = with pkgs; [
    # core
    neovim
    git
    curl
    wget
    unzip
    btop
    fastfetch

    # terminal / wayland utils
    kitty
    wl-clipboard
    grim
    slurp

    # apps
    vesktop
    ayugram-desktop    thunar
    vlc
    spicetify-cli
    codex

    # audio / media / brightness
    pavucontrol
    playerctl
    brightnessctl
    ddcutil

    # eye candy
    cava
    cmatrix
  ];

  # ── Nix ─────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Do NOT change this after install.
  system.stateVersion = "26.05";
}
