# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  negate = x: !x;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "sphinx"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;
    # wicd.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlo1.useDHCP = true;

    # Open ports in the firewall.
    firewall = {
     allowedTCPPorts = [
       22 53 80 8000 6667 6697 7881
       19000 19001 19002 19003 19004 # for expo cli development
     ];
    };

  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";

  nix = {
    binaryCaches = [
      "https://nixcache.reflex-frp.org"
    ];
    binaryCachePublicKeys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    ];
  };

  nixpkgs.config = {
    # allow propietary components
    allowUnfree = true;

    # sadly, source appears to have been removed
    # chromium.enablePepperFlash = true;

    firefox.enablePlasmaBrowserIntegration = true;

    packageOverrides = pkgs: {
      # custom emacs with imagemagick support
      emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
        imagemagick = pkgs.imagemagick;
      }) (attrs: {
        postInstall = attrs.postInstall + ''
        rm $out/share/applications/emacs.desktop
        '';
      });

      # TODO accelerated video playback - using intel's hybrid driver
    };

  };

  #  List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    etc = {
      "ofono/phonesim.conf".source = pkgs.writeText "phonesim.conf" ''
        [phonesim]
        Driver=phonesim
        Address=127.0.0.1
        Port=12345
      '';
    };
    systemPackages = with pkgs; [
      # text readers & editors
      vim
      emacs
      vscode
      okular
      kate
      zotero
      libreoffice

      # internet
      firefox
      chromium
      ktorrent
      zoom-us
      teams

      # development
      # ### compilers & interpreters
      python3
      nodejs
      yarn
      idris
      openjdk
      racket

      # ### devops
      docker-compose

      # ### command line interfaces
      awscli

      # system
      cachix
      nix-prefetch-git
      gparted
      gnome3.gnome-disk-utility
      filelight
      powertop
      grsync
      ark
      wine-staging

      # utilities
      killall
      wget
      pass
      git
      tree
      kcalc
      kcharselect
      unzip
      zip
      inxi
      glxinfo
      openssl
      direnv
      speedtest-cli
      pciutils
      dmidecode
      smartmontools
      lm_sensors
      nix-index

      # ## snippy dependencies
      dmenu xsel xdotool

      # random stuff
      kdeFrameworks.oxygen-icons5
      neofetch
    ];
  };

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
    # temporary: enable MySQL
    # mysql.enable = true;
    # mysql.package = pkgs.mysql;

    # ofono for headset microphone
    ofono.enable = true;

    # Enable fstrim for ssd
    fstrim.enable = true;

    # Enable the lorri daemon for nix-shell management.
    lorri.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # enable emacs as a daemon.
    emacs.enable = true;
    emacs.defaultEditor = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable syncthing
    syncthing = {
      enable = true;
      user = "chava";
      dataDir = "/home/chava/Downloads";
      configDir = "/home/chava/Downloads/.config/syncthing";
    };

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
      extraModules = [ pkgs.pulseaudio-modules-bt ];
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

  systemd.user.services = {
    # define a service for bluetooth headset controller
    mpris-proxy = {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      script = "${pkgs.bluezFull}/bin/mpris-proxy";
      wantedBy = [ "default.target" ];
   };

    # fixes persp-mode shutdown bug
    emacs = {...}: {
      options = {
        serviceConfig = pkgs.lib.mkOption {
          apply = attrs: attrs // {
            ExecStop = ''${pkgs.emacs}/bin/emacsclient --eval
            "(let ((kill-emacs-hook
                   (append kill-emacs-hook '(recentf-save-list))))
                  (save-buffers-kill-emacs t))"'';
          };
        };
      };
      config = {};
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
