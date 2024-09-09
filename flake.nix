{
  description = "Dockerized android emulator";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }@inputs:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = (import nixpkgs) {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
    hci-effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
  in {
    packages = rec {
      default = docker;
      docker = pkgs.callPackage ./package/docker.nix {};
    };
    apps = rec {
      emulator = {
        type = "app";
        program = ''${pkgs.androidenv.emulateApp {
            name = "android-emulator";
            abiVersion = "x86_64";
            platformVersion = "33";
            systemImageType = "google_apis_playstore";
            androidEmulatorFlags = "-no-window";
          }}/bin/run-test-emulator'';
      };
      default = emulator;
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
        }).androidsdk)
      ];
    };
  });
}
