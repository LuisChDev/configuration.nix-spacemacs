{
  allowUnfree = true;
  allowUnsupportedSystem = true;
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {

      # here I keep software that's useful, but I'm not quite sure if to
      # include permanently

      name = "my-packages";
      paths = [
        lxqt.pavucontrol-qt

        # ### graphical software
        # auto generated graphs (from code or ASCII)
        graphviz
        plantuml
        ditaa

        # graphing software
        drawio
        geogebra
        imagemagick

        # utilities
        openssl
        direnv

        (texlive.combine {
          inherit (texlive) scheme-medium collection-latexextra;
        })

        (aspellWithDicts (ds: [ds.en ds.es]))
      ];
    };
  };
}
