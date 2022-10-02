# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs, dotfile-sync, whitesur-kde, ... }:

let
  negate = x: !x;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    dotfile-sync.nixosModule
  ];

  services.dotfile-sync = {
    enable = false;
    dotfilesDir = /home/chava/dotfiles_test;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_19;

  # apparently needed for nvidia power management
  boot.kernelParams = [ "nvidia.NVreg_DynamicPowerManagement=0x02" ];

  networking = {
    hostName = "phalanx"; # Define your hostname.
    networkmanager.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
    interfaces.wlp4s0.useDHCP = true;

    # Open ports in the firewall.
    firewall = {
      allowedTCPPorts = [
        22
        53
        80
        8000
        6667
        6697
        7881
        19000
        19001
        19002
        19003
        19004 # for expo cli development
      ];
    };

  };

  # Select internationalisation properties.
  i18n = { defaultLocale = "en_US.UTF-8"; };

  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";

  nix = {
    # makes <nixpkgs> the same as the system's pinned revision
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    # creates a flake registry entry for the same
    registry = {
      pkgs = {
        from = {
          id = "pkgs";
          type = "indirect";
        };
        to = {
          type = "path";
          path = "${nixpkgs}";
        };
      };
    };

    settings = {
      auto-optimise-store = true;

      trusted-users = [ "root" "@wheel" ];
      binary-caches = [ "https://nixcache.reflex-frp.org" ];
      binary-cache-public-keys =
        [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
    };

    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

  };

  nixpkgs = {
    overlays = [
      (self: super: {
        nixos-option = let
          flake-compat = super.fetchFromGitHub {
            owner = "edolstra";
            repo = "flake-compat";
            rev = "b4a34015c698c7793d592d66adbab377907a2be8";
            sha256 = "sha256-Z+s0J8/r907g149rllvwhb4pKi8Wam5ij0st8PwAh+E=";
          };
          prefix =
            "(import ${flake-compat} { src = /etc/nixos; }).defaultNix.nixosConfigurations.\\$(hostname)";
        in super.runCommand "nixos-option" {
          buildInputs = [ super.makeWrapper ];
        } ''
          makeWrapper ${super.nixos-option}/bin/nixos-option $out/bin/nixos-option \
            --add-flags --config_expr \
            --add-flags "\"${prefix}.config\"" \
            --add-flags --options_expr \
            --add-flags "\"${prefix}.options\""
        '';
      })
    ];

    config = {
      # allow propietary components
      allowUnfree = true;
      firefox.enablePlasmaBrowserIntegration = true;

      packageOverrides = pkgs: {
        # custom emacs with imagemagick support
        emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
          imagemagick = pkgs.imagemagick;
          nativeComp = true;
        }) (attrs: {
          postInstall = attrs.postInstall + ''
            rm $out/share/applications/emacs.desktop
          '';
        });

        ark = pkgs.ark.override { unfreeEnableUnrar = true; };

        whitesur-kde-theme = whitesur-kde.defaultPackage.x86_64-linux;
        dotfile-sync = dotfile-sync.defaultPackage.x86_64-linux;
      };
    };
  };

  #  List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    # fix for Firefox scrolling
    variables.MOZ_USE_XINPUT2 = "1";

    homeBinInPath = true;
    # etc = {
    #   "ofono/phonesim.conf".source = pkgs.writeText "phonesim.conf" ''
    #     [phonesim]
    #     Driver=phonesim
    #     Address=127.0.0.1
    #     Port=12345
    #   '';
    # };
    systemPackages = with pkgs; [
      # text readers & editors
      vim
      emacs
      vscode # # need the latest version
      okular
      kate
      zotero
      libreoffice

      # internet
      firefox
      chromium
      # torbrowser
      ktorrent # probably will get rid of this
      qbittorrent
      zoom-us
      teams
      synology-drive-client

      # development
      # ### compilers & interpreters
      # I try not to keep too much in here, as that's the point of
      # nix development environments.
      python3
      nodejs
      scala
      sbt
      gcc
      nixfmt # don't know where else to put it
      # needed here so that we can use it as root
      rnix-lsp

      # ### devops
      docker-compose
      awscli2

      # system
      cachix
      nix-prefetch-git
      gparted
      gnome.gnome-disk-utility
      filelight
      grsync
      ark
      libsForQt5.dolphin-plugins
      kcalc
      konsole
      # wine-staging
      # winetricks

      # utilities
      killall
      wget
      pass
      xorg.xev
      gh
      git
      gitAndTools.gitflow
      tree
      kcharselect
      unzip
      zip
      unrar
      # inxi
      glxinfo
      openssl
      direnv
      speedtest-cli
      yt-dlp
      brightnessctl
      pciutils
      dmidecode
      # smartmontools
      # lm_sensors
      nix-index
      # ocrmypdf
      ffmpeg
      # poppler_utils
      nvidia-offload
      nixos-option
      nix-index
      pdftk

      # ## snippy dependencies
      dmenu
      xsel
      xdotool

      # random stuff
      oxygen-icons5
      neofetch
      whitesur-kde-theme

      # compatibility with pipewire
      plasma-pa
    ];
  };

  fonts.fonts = with pkgs; [ source-code-pro ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam.enable = true;
  };

  # change sudo timeout
  security = {
    sudo.extraConfig = ''
      Defaults	timestamp_timeout=10
    '';

    rtkit.enable = true;
  };

  # List services that you want to enable:

  services = {
    # enable power management through TLP.
    # tlp.enable = true;

    teamviewer.enable = true;

    pipewire = {
      enable = true;

      pulse.enable = true;
      jack.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
    };

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

    # enable the clam antivirus software.
    clamav = {
      # daemon.enable = true;  # we'll only run it manually
      updater.enable = true;
    };

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

      # proprietary graphics driver
      videoDrivers = [ "nvidia" ];

      # Enable the KDE Desktop Environment.
      displayManager.sddm = {
        enable = true;
        theme = "WhiteSur";
      };
      desktopManager.plasma5.enable = true;
    };
  };

  # enable Docker containers.
  virtualisation = {
    docker.enable = true;
    # anbox.enable = true;
  };

  hardware = {
    # enable bluetooth.
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    nvidia = {
      powerManagement = {
        enable = true;
        finegrained = true;
      };

      nvidiaPersistenced = true;
      modesetting.enable = true;

      prime = {
        offload.enable = true;

        amdgpuBusId = "PCI:5:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chava = {
    isNormalUser = true;
    extraGroups =
      [ "adbusers" "wheel" "docker" "wireshark" ]; # Enable ‘sudo’ for the user.
    hashedPassword =
      "***REMOVED***";
    home = "/home/chava";
  };

  systemd.user.services = {
    # define a service for bluetooth headset controller
    mpris-proxy = {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      script = "${pkgs.bluez}/bin/mpris-proxy";
      wantedBy = [ "default.target" ];
    };

    # fixes persp-mode shutdown bug
    emacs = { ... }: {
      options = {
        serviceConfig = pkgs.lib.mkOption {
          apply = attrs:
            attrs // {
              ExecStop = ''
                ${pkgs.emacs}/bin/emacsclient --eval
                  "(let ((kill-emacs-hook
                    (append kill-emacs-hook '(recentf-save-list))))
                    (save-buffers-kill-emacs t))"
              '';
            };
        };
      };
      config = { };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.11"; # Did you read the comment?

}

