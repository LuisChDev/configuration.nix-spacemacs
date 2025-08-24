  # Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config,
  pkgs,
  nixpkgs,
  whitesur-kde,
  ...
}:

let
  chavaPassword = # secret file
    (builtins.fromJSON (builtins.readFile ./passwords.json)).chava;
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # dotfile-sync.nixosModule
    # nordvpn.nixosModules.x86_64-linux.default
  ];

  # services.dotfile-sync = {
  #   enable = false;
  #   dotfilesDir = /home/chava/dotfiles_test;
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  # apparently needed for nvidia power management
  boot.kernelParams = [ "nvidia.NVreg_DynamicPowerManagement=0x02" ];

  boot.supportedFilesystems = [ "ntfs" ];

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
      checkReversePath = false;
      allowedUDPPorts = [ 1194 ];
      allowedTCPPorts = [
        22
        53
        80
        443
        6667
        6697
        7881
        8000

        # 8080
        8081 # also expo

        9418  # git protocol port
        19000
        19001  # for expo cli development
      ];
    };
  };

  # Select internationalisation properties.
  i18n = { defaultLocale = "en_US.UTF-8"; };

  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";
  time.hardwareClockInLocalTime = true;  # for dual boot with Windows

  nix = {
    # makes <nixpkgs> the same as the system's pinned revision
    # nixPath = [ "nixpkgs=${nixpkgs}" ];
    # creates a flake registry entry for the same
    # registry = {
    #   pkgs = {
    #     from = {
    #       id = "pkgs";
    #       type = "indirect";
    #     };
    #     to = {
    #       type = "path";
    #       path = "${nixpkgs}";
    #     };
    #   };
    # };

    # no longer needed; flake systems have this automatically

    settings = {
      auto-optimise-store = true;

      trusted-users = [ "root" "@wheel" ];
      binary-caches = [ "https://nixcache.reflex-frp.org" ];
      binary-cache-public-keys =
        [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
    };

    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

  };

  nixpkgs = {
    config = {
      # allow propietary components
      allowUnfree = true;

      packageOverrides = pkgs: {
        # emacs = pkgs.lib.overrideDerivation
        #   (pkgs.emacs.override {
        #     imagemagick = pkgs.imagemagick;
        #     nativeComp = true;
        #   })
        #   (attrs: {
        #     postInstall = attrs.postInstall + ''
        #       rm $out/share/applications/emacs.desktop
        #     '';
        #   });

        # ark = pkgs.kdePackages.ark.override { unfreeEnableUnrar = true; };

        whitesur-kde-theme = whitesur-kde.defaultPackage.x86_64-linux;
        # dotfile-sync = dotfile-sync.defaultPackage.x86_64-linux;

        # nordvpn = nordvpn.packages.x86_64-linux.default;
      };
    };
  };

  #  List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    # fix for Firefox scrolling
    variables.MOZ_USE_XINPUT2 = "1";
    homeBinInPath = true;

    # try to keep here only the packages that absolutely have to be
    # available for super-user or at login
    systemPackages = with pkgs; [
      # text readers & editors (to support development on sudo env)
      vim-full
      # emacs  ## enabled as a service below
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          ms-python.python
          vspacecode.vspacecode
          vspacecode.whichkey
          scalameta.metals
          scala-lang.scala
        ];
      })

      # internet
      firefox
      chromium

      # needed here so that we can use it as root (as in configuration.nix)
      nixfmt-rfc-style

      # system
      cachix
      nix-prefetch-git
      gparted
      gnome-disk-utility
      kdePackages.filelight
      grsync
      kdePackages.ark
      kdePackages.dolphin-plugins
      kdePackages.qtmultimedia
      kdePackages.sddm-kcm
      kdePackages.kcalc
      kdePackages.konsole
      nh

      # utilities
      killall
      wget
      pass
      xorg.xev
      gh
      git
      git-filter-repo
      gitAndTools.gitflow
      tree
      kdePackages.kcharselect
      unzip
      zip
      unrar
      # inxi
      glxinfo
      openssl
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
      pdftk
      patchelf
      piper

      # random stuff (required for desktop env)
      kdePackages.oxygen-icons
      neofetch
      whitesur-kde-theme
      whitesur-kde

      # compatibility with pipewire
      kdePackages.plasma-pa
    ];
  };
  
  fonts.packages = with pkgs; [
    source-code-pro
    corefonts
    vista-fonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam.enable = true;
    kdeconnect.enable = true;
    wireshark.enable = true;

    direnv.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  security = {
    # change sudo timeout
    sudo.extraConfig = ''
      Defaults	timestamp_timeout=30
    '';

    rtkit.enable = true;
  };

  # List services that you want to enable:

  services = {
    # enable power management through TLP.
    # tlp.enable = true;

    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
      submissionUrl = "https://api.beacondb.net/v2/geosubmit";
    };

    # nordvpn.enable = true;

    postgresql = {
      enable = true;
      enableJIT = true;
      package = pkgs.postgresql_17;  # update once in a while
    };

    ratbagd.enable = true;

    jackett.enable = true;

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

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # enable emacs as a daemon.
    emacs.enable = true;
    emacs.package = (
      pkgs.emacsPackagesFor pkgs.emacs30
    ).emacsWithPackages (epkgs: with epkgs; [
      vterm
      zmq
      treesit-grammars.with-all-grammars
    ]);
    emacs.defaultEditor = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # enable the clam antivirus software.
    # clamav = {
    #   daemon.enable = true;  # we'll only run it manually
    #   updater.enable = true;
    # };

    # Enable syncthing
    syncthing = {
      enable = true;
      user = "chava";
      dataDir = "/home/chava/Downloads";
      configDir = "/home/chava/Downloads/.config/syncthing";
    };

    # Enable touchpad support.
    libinput.enable = true;

    # Enable the KDE Desktop Environment.
    displayManager.sddm = {
      enable = true;
      theme = "WhiteSur";
      wayland.enable = false;
    };
    desktopManager.plasma6.enable = true;

    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      xkb = {
        layout = "latam,ru,gr,us";
        variant = ",phonetic,,";
        options = "eurosign:e";
      };

      # proprietary graphics driver
      videoDrivers = [ "nvidia" ];
    };
  };

  # enable Docker containers.
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  hardware = {
    # enable bluetooth.
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    nvidia-container-toolkit.enable = true;
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
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
      # Enable ‘sudo’ for the user.
      [ "adbusers" "wheel" "docker" "wireshark" "nordvpn" "vboxusers" ];

    # include your hashed passwords in a .json file in the format
    # { "username": "password" }, but don't commit it ;)
    # (see above in the beginning of the file on how to import it)
    # passwords are generated with `mkpasswd <your password here>`

    # when using flakes, if you keep your config in a repo and symlink it
    # elsewhere, nix will complain that it can't find the passwords file. This
    # is because flakes only knows about files known also to git. You can solve
    # this in a number of ways:

    # 1. just `git add` the file when you're about to run any nix command, and
    # then remove it.
    # 2. I'll think of a better solution some day ¯\_(ツ)_/¯

    # this is just a problem if you're uploading this repo to a public place
    # (i.e. github). if it's 100% private then maybe consider just commiting the
    # file

    # by the way, if you delete this user IT WILL BE DELETED FROM THE SYSTEM, EVEN
    # IF YOU HAVE users.mutableUsers SET IN PLACE
    hashedPassword = chavaPassword;
    home = "/home/chava";
  };

  systemd.user.services = {

    # fixes persp-mode shutdown bug
    emacs = { ... }: {
      config = {};

      options = {
        serviceConfig = pkgs.lib.mkOption {
          apply = attrs:
            attrs // {
              ExecStop = ''
                ${pkgs.emacs}/bin/emacsclient --eval "(let ((kill-emacs-hook (append kill-emacs-hook '(recentf-save-list)))) (save-buffers-kill-emacs t))"
              '';
            };
        };
      };
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

