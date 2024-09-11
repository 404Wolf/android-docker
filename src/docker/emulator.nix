{
  android-composition,
  adb-port,
  emulator-args,
  dockerTools,
  busybox,
  writeShellApplication,
  buildEnv,
  androidenv,
  ...
}: let
  run-android-emulator = writeShellApplication {
    name = "run-android-emulator";
    runtimeInputs = [
      busybox
      android-composition.androidsdk
    ];
    text = ''
      ${builtins.readFile ../scripts/setup-environment.sh}
      ${builtins.readFile ../scripts/handle-shutdown.sh}

      ${androidenv.emulateApp emulator-args}/bin/run-test-emulator & :
      ${builtins.readFile ../scripts/wait-for-boot.sh}

      adb devices
      adb shell settings put global adb_wifi_enabled 1
      adb tcpip adb-port
      adb devices
      echo "Started android emulator. PID: $!"
    '';
  };

  android-sdk = android-composition.androidsdk;
in
  dockerTools.buildImage {
    name = "AndroidEmulator";
    tag = "latest";

    config = {
      Env = [
        "ANDROID_SDK_ROOT=${android-sdk}/libexec/android-sdk"
        "ANDROID_NDK_ROOT=${android-sdk}/libexec/android-sdk/ndk-bundle"
      ];
      EXPOSE = [
        adb-port
      ];
      copyToRoot = buildEnv {
        name = "root";
        pathsToLink = ["/bin"];
        paths = [run-android-emulator];
      };
    };
  }
