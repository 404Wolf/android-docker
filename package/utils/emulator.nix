{pkgs, ...}:
pkgs.writeShellScriptBin "android-emulator" ''
  ${builtins.readFile ../scripts/handle-shutdown.sh}
  
  # adb start
  ${pkgs.androidenv.emulateApp {
    name = "android-emulator";
    abiVersion = "x86_64";
    platformVersion = "30";
    systemImageType = "google_apis_playstore";
    androidEmulatorFlags = "-no-window";
  }}/bin/run-test-emulator & :
  echo "Started android emulator. PID: $!"

  # ${builtins.readFile ../scripts/wait-for-boot.sh}
  # ${builtins.readFile ../scripts/setup-scrcpy.sh}
  # ${builtins.readFile ../scripts/start-ffmpeg.sh}
''
