{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
    buildInputs = [
        pkgs.ocaml
        pkgs.ocamlPackages.dune_3
        pkgs.ocamlPackages.menhir
    ];
}