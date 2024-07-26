{ pkgs ? (import <nixpkgs> {})}:
pkgs.mkShell {
    buildInputs = (with pkgs; [
        ocaml
        cmake
    ]) ++ (with pkgs.ocamlPackages; [
        ocamlbuild findlib
    ]);
}