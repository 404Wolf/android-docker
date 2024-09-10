{pkgs, ...}:
pkgs.writeShellScriptBin "android-emulator" ''
  ${builtins.readFile ../scripts/setup-environment.sh}
  ${builtins.readFile ../scripts/handle-shutdown.sh}

  ${pkgs.androidenv.emulateApp {
    name = "android-emulator";
    abiVersion = "x86_64";
    platformVersion = "33";
    systemImageType = "default";
    androidEmulatorFlags = "-no-window -no-metrics -verbose -skip-adb-auth";
  }}/bin/run-test-emulator & :
  ${builtins.readFile ../scripts/wait-for-boot.sh}

  adb devices
  adb shell settings put global adb_wifi_enabled 1
  adb tcpip 5555
  adb devices
  echo "Started android emulator. PID: $!"

  ${builtins.readFile ../scripts/setup-scrcpy.sh}
  ${builtins.readFile ../scripts/start-ffmpeg.sh}
''
