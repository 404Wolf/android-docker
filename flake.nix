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
    in {
      packages = rec {
        default = docker;
        docker = pkgs.callPackage ./package/docker.nix {};
      };
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.podman-compose
          pkgs.podman
          pkgs.arion
          ((pkgs.androidenv.composeAndroidPackages {
              cmdLineToolsVersion = "8.0";
              toolsVersion = "26.1.1";
              platformToolsVersion = "34.0.4";
              platformVersions = ["34"];
            })
            .androidsdk)
        ];
      };
    })
    // {
      pkgs = (import nixpkgs) {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    };
}
