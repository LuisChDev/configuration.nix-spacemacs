{ pkgs }: {
  home = {
    username = "chava";
    homeDirectory = "/home/chava";
    stateVersion = "22.11";
    packages = with pkgs; [
      # multimedia software
      # ### auto generated graphs (from code or ASCII)
      graphviz
      # plantuml
      # ditaa

      # ### graphical software
      kolourpaint
      spectacle
      drawio
      # geogebra
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
      minecraft
      # minetest
      wesnoth
      # vbam
      # zeroad

      gnome3.cheese
      vmpk
      sl

      # TeX packages
      (texlive.combine {
        inherit (texlive)
          scheme-medium collection-latexextra collection-bibtexextra;
      })

      # dictionaries
      (aspellWithDicts (ds: [ ds.en ds.es ]))
    ];
  };

  programs.git = {
    enable = true;
    userEmail = "luischa123@gmail.com";
    userName = "Luis Chavarriaga";
    signing.key = "F1C3B896";
    signing.signByDefault = false;
    extraConfig = { merge = { confictstyle = "diff3"; }; };
  };
}
