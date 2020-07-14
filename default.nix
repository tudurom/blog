with import <nixpkgs> { };

let jekyllEnv = bundlerEnv rec {
  name = "jekyllEnv";
  inherit ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};
in
  stdenv.mkDerivation rec {
    name = "tudorBlog";
    version = "unstable";

    src = ./.;

    nativeBuildInputs = [ jekyllEnv bundler ruby ];
    dontInstall = true;

    buildPhase = ''
      buildDir="$(pwd)"

      cp -rf $src/* "$buildDir"

      ${jekyllEnv}/bin/jekyll build -d "$out" --trace
    '';
  }
