{
  description = "Dockerized android emulator";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    scrcpy-server.url = "github:browser-phone/scrcpy";
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

      android-composition = pkgs.androidenv.composeAndroidPackages {
        cmdLineToolsVersion = "8.0";
        toolsVersion = "26.1.1";
        platformToolsVersion = "34.0.4";
        platformVersions = ["34"];
      };

      emulator-args = {
        name = "android-emulator";
        abiVersion = "x86_64";
        platformVersion = "33";
        systemImageType = "default";
        androidEmulatorFlags = "-no-window -no-metrics -verbose -skip-adb-auth -no-snapshot-save";
      };
    in {
      packages = rec {
        default = docker;
        docker = pkgs.callPackage ./src/docker {
          inherit android-composition emulator-args;
          scrcpy-server = inputs.scrcpy-server.packages.${system}.default;
          dockerTools.buildImage = args:
            pkgs.dockerTools.buildImage (args
              // {
                compressor = "none";
                buildVMMemorySize = 8128;
                diskSize = 2048;
              });
        };
      };
      devShells.default = pkgs.mkShell {
        PODMAN_IGNORE_CGROUPSV1_WARNING = "1";
        packages = [
          pkgs.podman-compose
          pkgs.podman
          pkgs.arion
          pkgs.scrcpy
          (pkgs.androidenv.composeAndroidPackages {
            cmdLineToolsVersion = "8.0";
            toolsVersion = "26.1.1";
            platformToolsVersion = "34.0.4";
            platformVersions = ["34"];
            includeEmulator = true;
          })
          .androidsdk
        ];
      };
    });
}
