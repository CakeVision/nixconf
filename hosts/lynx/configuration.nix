# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #_# networking.hostName = "nixos"; # Define your hostname.

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # COMMENTED OUT FOR CONFLICT WITH HOME-MANAGER
  #users.users.cake = {
  #  isNormalUser = true;
  #  description = "Cake";
  #  extraGroups = [ "networkmanager" "wheel" ];
  #  packages = with pkgs; [
  #    kdePackages.kate
  #    #  thunderbird
  #  ];
  #};
  # define extraGroups
  users.extraGroups = {
    haproxy = {
      gid = 1001;
    };
  };
  #define extraUsers
  users.extraUsers.haproxy = {
    isSystemUser = true;
    uid = 1001;
    group = "haproxy";
    extraGroups = [ "networkmanager" ];
    shell = "/bin/false";
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # thought about adding haproxy as a service, but the need to define the config in the system build is 
  # not fit for development usage, only for deployment
  #
  # add haproxy to the ssystem
  # services.haproxy =
  #   {
  #     enable = true;
  #     user = "haproxy";
  #     group = "haproxy";
  #     config = ''
  #              # Global settings
  #       global
  #           log /dev/log local0
  #           log /dev/log local1 notice
  #           maxconn 2000
  #           daemon
  #           stats socket /run/haproxy/admin.sock mode 660 level admin
  #           stats timeout 30s

  #       # Default settings
  #       defaults
  #           log global
  #           mode http
  #           option httplog
  #           option dontlognull
  #           timeout connect 5000ms
  #           timeout client  50000ms
  #           timeout server  50000ms
  #           maxconn 2000

  #       # Frontend configuration (listens on port 25000)
  #       frontend echo_frontend
  #           bind *:25000
  #           default_backend echo_backend

  #       # Backend configuration (round-robin to Go echo servers)
  #       backend echo_backend
  #           balance roundrobin
  #           option httpchk GET /
  #           server echo1 127.0.0.1:1323 check
  #           server echo2 127.0.0.1:1324 check
  #           server echo3 127.0.0.1:1325 check

  #     '';
  #   };
  # Add tmux system-wide
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "C-Space";
    # keyMode = vi sets this settings in the tmux.conf
    #   bind h select-pane -L
    #   bind j select-pane -D 
    #   bind k select-pane -U
    #   bind l select-pane -R
    #
    # defaultShortcut = "C-Space";
    # unbind C-b
    # set -g prefix C-Space
    # bind C-Space send-prefix


    extraConfigBeforePlugins = '' 

      set-option -g default-command "/run/current-system/sw/bin/bash"
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on


      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      '';
    plugins = with pkgs.tmuxPlugins;
      [
        yank
        catppuccin
        vim-tmux-navigator

      ];


  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    home-manager
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.blueman.enable = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
