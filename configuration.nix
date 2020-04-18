# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "sphinx"; # Define your hostname.
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    wicd.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlo1.useDHCP = true;

    # Open ports in the firewall.
    firewall = {
     allowedTCPPorts = [
       22 53 80 8000 6667 6697 7881
     ];
    };

  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
  };


  # Set your time zone.
  time.timeZone = "America/Bogota";

  # allow propietary components
  nixpkgs.config = {
    allowUnfree = true;
    firefox.enablePlasmaBrowserIntegration = true;
  };


  #  List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # text readers & editors
    vim
    emacs
    okular
    kate
    zotero
    libreoffice
    (texlive.combine {
      inherit (texlive) scheme-medium collection-latexextra;
    })

    # internet
    firefox
    chromium
    ktorrent
    slack

    # development
    postman
    python3

    ## C/C++
      # gcc  # clang
      # ccls
      # cmake
    nodejs
    docker-compose

    # graphics & multimedia
    kdeApplications.kolourpaint
    kdeApplications.spectacle
    vlc
    amarok

    # system
    gparted
    gnome3.gnome-disk-utility
    filelight
    powertop
    grsync

    # utilities
    killall
    wget
    pass
    git
    tree
    autokey
    kcalc
    kcharselect
    ispell
    unzip
    zip

    # crap
    kdeFrameworks.oxygen-icons5
    neofetch

  ];

  # start powertop on startup
  powerManagement.powertop.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # change sudo timeout
  security.sudo.extraConfig = ''
Defaults	timestamp_timeout=10
'';

  # List services that you want to enable:

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # enable emacs as a daemon.
    # emacs.enable = true;
    # emacs.defaultEditor = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      layout = "latam,ru,gr,us";
      xkbVariant = ",phonetic,,";
      xkbOptions = "eurosign:e";

      # Enable touchpad support.
      libinput.enable = true;

      # Enable the KDE Desktop Environment.
      displayManager.sddm = {
       enable = true;
       theme = "elarun";
      };
      desktopManager.plasma5.enable = true;
    };
  };


  # enable Docker containers.
  virtualisation.docker.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    # enable bluetooth.
    bluetooth = {
     enable = true;
     package = pkgs.bluezFull;
    };

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chava = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "***REMOVED***";
    home = "/home/chava";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
