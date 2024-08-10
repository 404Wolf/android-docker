{pkgs, ...}: let
  run-android-emulator = (import ./utils/emulator.nix) {inherit pkgs;};
  android-composition = (import ./utils/composition.nix) {inherit pkgs;};
  android-sdk = android-composition.androidsdk;
in
  pkgs.dockerTools.buildImage {
    name = "android-emulator";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "root";
      pathsToLink = ["/bin"];
      paths = [
        pkgs.coreutils
        pkgs.busybox
        pkgs.bash
        android-sdk
      ];
    };

    config = {
      Env = [
        "ANDROID_SDK_ROOT=${android-sdk}/libexec/android-sdk"
        "ANDROID_NDK_ROOT=${android-sdk}/libexec/android-sdk/ndk-bundle"
      ];
      EXPOSE = [
        "5555" # ADB port
        "5554" # Emulator port
        "6666" # TCP video port
        "6667" # TCP audio port
        "6668" # TCP data port
        "7777" # RTP video port
        "7778" # RTP audio port
      ];
      Cmd = ["./${run-android-emulator}/bin/android-emulator"];
    };

    extraCommands = ''
      mkdir -p tmp/android-unknown/.android
    '';
  }
