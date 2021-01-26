with import <nixpkgs> { };

let jekyllEnv = bundlerEnv rec {
  name = "jekyllEnv";
  inherit ruby;
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
