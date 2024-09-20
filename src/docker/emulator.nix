{
  android-composition,
  adb-port,
  emulator-args,
  dockerTools,
  busybox,
  scripts,
  writeShellApplication,
  buildEnv,
  androidenv,
  callPackage,
  ...
}: let
  run-android-emulator = writeShellApplication {
    name = "run-android-emulator";
    runtimeInputs = [
      busybox
      android-composition.androidsdk
      (androidenv.emulateApp emulator-args)
      scripts.wait-for-boot
      scripts.handle-shutdown
      scripts.setup-environment
    ];
    text = ''
      setup-environment
      handle-shutdown

      run-test-emulator & :
      wait-for-boot

      adb devices
      adb shell settings put global adb_wifi_enabled 1
      adb tcpip ${adb-port}
      adb devices
      echo "Started android emulator. PID: $!"
    '';
  };

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
      EXPOSE = [
        adb-port
      ];
    };
    copyToRoot = buildEnv {
      name = "root";
      pathsToLink = ["/bin"];
      paths = [run-android-emulator];
    };
  }
