{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    llvm_15
    pypy310
    lua
    luajit
  ];
}
