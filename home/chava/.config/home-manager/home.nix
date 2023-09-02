{ config, pkgs, ... }: {
  home = {
    username = "chava";
    homeDirectory = "/home/chava";
    stateVersion = "22.11";

    packages = with pkgs; [
      # multimedia software
      # ### auto generated graphs (from code or ASCII)
      graphviz
      plantuml
      ditaa

      # ### graphical software
      kolourpaint
      spectacle
      drawio
      imagemagick
      gwenview
      gimp
      # kdenlive
      inkscape

      # ### playback
      vlc
      simplescreenrecorder
      clementine

      # ### fun
      wesnoth
      # zeroad
      anki-bin
      gnome.cheese
      vmpk
      sl

      # should not be here but whatevs
      jdk
      poetry

      # development
      # ## compilers & interpreters
      # ## I try not to keep too much in here, as that's the point of
      # ## nix development environments.
      python3
      python3Packages.python-lsp-server
      nodejs
      # scala
      # scala-cli
      dotty
      sbt
      gcc

      # ## devops
      docker-compose
      awscli2

      # networking
      ktorrent
      qbittorrent
      zoom-us
      synology-drive-client
      monero-gui

      # text editing and citations
      okular
      kate
      zotero
      libreoffice

      # ## TeX packages
      (texlive.combine {
        inherit (texlive)
          scheme-medium collection-latexextra collection-bibtexextra;
      })

      # ## dictionaries
      (aspellWithDicts (ds: [ ds.en ds.es ]))

      # ## adding hunspell with multiple dictionaries
      (hunspellWithDicts (with hunspellDicts; [ en_US es_CO es_ANY ]))

      # ## snippy dependencies
      dmenu
      xsel
      xdotool

    ];
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "luischa123@gmail.com";
    userName = "Luis Chavarriaga";
    signing.key = "F1C3B896";
    signing.signByDefault = false;

    extraConfig = {
      merge = { confictstyle = "diff3"; };
      github = {
        oauth-token = "d0d81f444217eff7193d6a551bef703528f2438b";
        user = "LuisChDev";
      };
      credential = {
        helper = "!aws --profile tecnogold codecommit credential-helper $@";
        UseHttpPath = "true";
      };
      init = {
        defaultBranch = "master";
      };
      url = {
        "https://" = {
          insteadOf = "git://";
        };
      };
    };

    aliases = {
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
    };
  };
}
