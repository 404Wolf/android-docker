{
  description = "Dockerized android emulator";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = (import nixpkgs) {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    in rec {
      packages = {
        docker = pkgs.callPackage ./package/docker.nix {};
        runner = pkgs.callPackage ./package/runner.nix {};
      };
      apps = {
        runner = flake-utils.lib.mkApp {
          name = "run-emulator";
          drv = packages.runner;
        };
      };
      devShells.default = pkgs.mkShell {
        packages = let
          android-composition = (import ./package/utils/composition.nix) {inherit pkgs;};
          android-sdk = android-composition.androidsdk;
        in [
          android-sdk
        ];
      };
    });
}
