{ pkgs ? import <nixpkgs> {}, ... }:
let
  myJre = pkgs.temurin-jre-bin-11;
  sbtWithJre = pkgs.sbt.override { jre = myJre; };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    hyperfine
    llvm_15
    pypy310
    lua
    luajit
    nodejs
    # effekt, asm
    sbtWithJre myJre
    # koka
    stack cmake
    # eff
    ocaml
    ocamlPackages.ocamlformat_0_25_1
    ocamlPackages.menhir
    ocamlPackages.dune_3
  ];
}
