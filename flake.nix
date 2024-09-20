{
  description = "Dockerized android emulator";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    scrcpy.url = "github:browser-phone/scrcpy";
  };

  outputs = {
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
        androidEmulatorFlags = "-no-window -no-metrics -verbose -skip-adb-auth";
      };
    in {
      packages = rec {
        default = docker;
        docker = pkgs.callPackage ./src/docker {
          inherit android-composition emulator-args scripts;
        };
        scripts = pkgs.callPackage ./src/scripts {
          inherit android-composition emulator-args;
        };
      };
      devShells.default = pkgs.mkShell {
        PODMAN_IGNORE_CGROUPSV1_WARNING = "1";
        packages = [
          pkgs.podman-compose
          pkgs.podman
          ((pkgs.androidenv.composeAndroidPackages {
              cmdLineToolsVersion = "8.0";
              toolsVersion = "26.1.1";
              platformToolsVersion = "34.0.4";
              platformVersions = ["34"];
              includeEmulator = true;
            })
            .androidsdk)
          (inputs.scrcpy.packages.${system}.scrcpy)
        ];
      };
    });
}
