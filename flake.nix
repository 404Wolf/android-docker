{
  description = "Dockerized android emulator";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    scrcpy-server = "github:browser-phone/scrcpy";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
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
        docker = pkgs.callPackage ./package/docker.nix {
          scrcpy-server = inputs.scrcpy-server.${system}.packages.default;
        };
      };
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.podman-compose
          pkgs.podman
          pkgs.arion
          pkgs.scrcpy
          ((pkgs.androidenv.composeAndroidPackages {
              cmdLineToolsVersion = "8.0";
              toolsVersion = "26.1.1";
              platformToolsVersion = "34.0.4";
              platformVersions = ["34"];
              includeEmulator = true;
            })
            .androidsdk)
        ];
      };
    });
}
