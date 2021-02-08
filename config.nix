{
  allowUnfree = true;
  allowUnsupportedSystem = true;
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {

      # here I keep software that's useful, but I'm not quite sure if to
      # include permanently
      # UPDATE: these will probably remain here 4ever lmao

      name = "my-packages";
      paths = [
        # multimedia software
        # ### auto generated graphs (from code or ASCII)
        graphviz
        plantuml
        ditaa
        # ### graphical software
        kdeApplications.kolourpaint
        kdeApplications.spectacle
        drawio
        geogebra
        imagemagick
        gwenview
        # ### playback
        vlc
        simplescreenrecorder
        # amarok
        # ### fun
        gnome3.cheese
        vmpk
        qsynth
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
