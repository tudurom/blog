{ pkgs ? import <nixpkgs> }:
let jekyllEnv = pkgs.bundlerEnv rec {
  name = "jekyllEnv";
  inherit (pkgs) ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};
in
  pkgs.stdenv.mkDerivation rec {
    name = "tudorBlog";
    version = "unstable";

    src = ./.;

    nativeBuildInputs = with pkgs; [ jekyllEnv bundler ruby ];
    dontInstall = true;

    buildPhase = ''
      buildDir="$(pwd)"

      cp -rf $src/* "$buildDir"

      ${jekyllEnv}/bin/jekyll build -d "$out" --trace
    '';
  }
