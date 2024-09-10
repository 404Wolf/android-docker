{
  pkgs,
  android-composition,
  adb-port,
  emulator-port,
  emulator-args,
  ...
}: let
  run-android-emulator = pkgs.writeShellScriptBin "run-android-emulator" ''
    ${builtins.readFile ../scripts/setup-environment.sh}
    ${builtins.readFile ../scripts/handle-shutdown.sh}

    ${pkgs.androidenv.emulateApp emulator-args}/bin/run-test-emulator & :
    ${builtins.readFile ../scripts/wait-for-boot.sh}

    adb devices
    adb shell settings put global adb_wifi_enabled 1
    adb tcpip 5555
    adb devices
    echo "Started android emulator. PID: $!"
  '';

  android-sdk = android-composition.androidsdk;
in
  pkgs.dockerTools.buildImage {
    fromImage = pkgs.callPackage ./base.nix {inherit android-composition;};
    name = "AndroidEmulator";
    tag = "latest";

    config = {
      Env = [
        "ANDROID_SDK_ROOT=${android-sdk}/libexec/android-sdk"
        "ANDROID_NDK_ROOT=${android-sdk}/libexec/android-sdk/ndk-bundle"
      ];
      EXPOSE = [
        adb-port
        emulator-port
      ];
      copyToRoot = pkgs.buildEnv {
        name = "root";
        pathsToLink = ["/bin"];
        paths = [run-android-emulator];
      };
    };
  }
