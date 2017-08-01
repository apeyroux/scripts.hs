{ pkgs ? import <nixpkgs> {}} :

with pkgs;

stdenv.mkDerivation {
    name = "script.hs";
    buildInputs = [
    haskellPackages.stack
    cabal2nix
    haskellPackages.directory
    haskellPackages.MissingH
    ];
}
