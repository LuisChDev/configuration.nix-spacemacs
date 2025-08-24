# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, nixos-wsl, ... }:

{
  imports = [
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.startMenuLaunchers = true;

  nix.settings.experimental-features = [
    "nix-command" "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    xorg.setxkbmap
    xdg-utils
    wsl-open

    nix-index
    nixd

    python3
    jdk

    scala-next
    sbt
  ];

  fonts.packages = with pkgs; [
    emacs-all-the-icons-fonts
    pkgs.nerd-fonts.symbols-only
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  services = {
    emacs.enable = true;
    emacs.package = (pkgs.emacsPackagesFor pkgs.emacs-gtk).emacsWithPackages (epkgs: [ epkgs.vterm ]);
  };

  programs = {
    direnv.enable = true;
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
