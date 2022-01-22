{
  description = "My blog";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-21.11;
    utils.url = github:numtide/flake-utils;
  };

  outputs = inputs@{ self, nixpkgs, utils }:
  utils.lib.eachDefaultSystem (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    packageName = "blog";
  in {
    packages.${packageName} = import ./default.nix { inherit pkgs; };
    defaultPackage = self.packages.${system}.${packageName};

    devShell = import ./shell.nix { inherit pkgs; };
  }
  );
}
