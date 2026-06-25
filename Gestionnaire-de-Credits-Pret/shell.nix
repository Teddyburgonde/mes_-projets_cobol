{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz") {} }:
pkgs.mkShell {
  packages = with pkgs; [
    gnu-cobol
    postgresql
    postgresql.lib
    gcc
    gnumake
    git
    pkg-config
    gmp
  ];
  
  shellHook = ''
    export PATH=${pkgs.gnu-cobol}/bin:$PATH
    export PKG_CONFIG_PATH=${pkgs.postgresql.lib}/lib/pkgconfig:$PKG_CONFIG_PATH
  '';
}
