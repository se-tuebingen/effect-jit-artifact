{ pkgs ? import <nixpkgs> {}, ... }:
let
  myJre = pkgs.temurin-jre-bin-11;
  sbtWithJre = pkgs.sbt.override { jre = myJre; };
  myOcamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
  myOcaml = myOcamlPackages.ocaml;
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
    libuv
    mlton
    # koka
    stack cmake
    # eff
    myOcaml
    myOcamlPackages.ocamlformat_0_25_1
    myOcamlPackages.menhir
    myOcamlPackages.dune_3
  ];
}
