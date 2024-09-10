{
  pkgs,
  android-composition ? (pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "8.0";
    toolsVersion = "26.1.1";
    platformToolsVersion = "34.0.4";
    platformVersions = ["34"];
  }),
  ...
}: let
  run-android-emulator = (import ./utils/emulator.nix) {inherit pkgs;};
  android-sdk = android-composition.androidsdk;

  base-image = pkgs.dockerTools.buildImage {
    name = "android-emulator-base";

    copyToRoot = pkgs.buildEnv {
      name = "root";
      pathsToLink = ["/bin"];
      paths = [
        pkgs.coreutils
        pkgs.busybox
        pkgs.bash
        android-composition.androidsdk
      ];
    };
  };
in
  pkgs.dockerTools.buildImage {
    fromImage = base-image;
    name = "android-emulator";
    tag = "latest";

    config = {
      Env = [
        "ANDROID_SDK_ROOT=${android-sdk}/libexec/android-sdk"
        "ANDROID_NDK_ROOT=${android-sdk}/libexec/android-sdk/ndk-bundle"
        "SCRCPY_SERVER_PATH=${./}"
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
      copyToRoot = [run-android-emulator];
      Cmd = ["./${run-android-emulator}/bin/android-emulator"];
    };
  }
