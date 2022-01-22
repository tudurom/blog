{ pkgs ? import <nixpkgs> }:
let jekyllEnv = pkgs.bundlerEnv rec {
  name = "jekyllEnv";
  inherit (pkgs) ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    jekyllEnv
    bundler
    ruby

    # keep this line if you use bash
    bashInteractive
  ];
}
