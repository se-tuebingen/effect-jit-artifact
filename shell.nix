{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    llvm_15
  ];
}
