{
  allowUnfree = true;
  firefox.enablePlasmaBrowserIntegration = true;
  packageOverrides = pkgs: with pkgs; {

    emacs = let
      modEmacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
        imagemagick = pkgs.imagemagick;
      }) (attrs: {
        postInstall = attrs.postInstall + ''
            rm $out/share/applications/emacs.desktop
          '';
      });
    in modEmacs;

    ark = pkgs.ark.override {
      unfreeEnableUnrar = true;
    };

    myPackages = pkgs.buildEnv {
      name = "my-packages";
      paths = [
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
            scheme-medium
            collection-latexextra
            collection-bibtexextra;
        })

        # dictionaries
        (aspellWithDicts (ds: [ds.en ds.es]))
      ];
    };
  };
}
