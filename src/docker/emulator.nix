{
  emulator-args,
  dockerTools,
  android-composition,
  scripts,
  buildEnv,
  callPackage,
  ...
}: let
  android-sdk = android-composition.androidsdk;
in
  dockerTools.buildImage {
    fromImage = callPackage ./base.nix {};
    name = "AndroidEmulator";
    tag = "latest";
    config = {
      Env = [
        "ANDROID_SDK_ROOT=${android-sdk}/libexec/android-sdk"
        "ANDROID_NDK_ROOT=${android-sdk}/libexec/android-sdk/ndk-bundle"
      ];
      EXPOSE = [5554];
    };
    copyToRoot = buildEnv {
      name = "root";
      pathsToLink = ["/bin"];
      paths = [
        (scripts.run-android-emulator {inherit emulator-args;})
        scripts.wait-for-boot
      ];
    };
  }
