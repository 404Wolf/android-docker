{pkgs, ...}:
pkgs.writeShellScriptBin "android-emulator" ''
  function shutdown(){
    echo "SIGTERM is received! Clean-up will be executed if needed!"
    PROCESS_ID=$(pgrep -f "start device")
    kill $PROCESS_ID
    sleep 10
  }
  trap shutdown SIGTERM

  adb start
  ${pkgs.androidenv.emulateApp {
    name = "android-emulator";
    abiVersion = "x86";
    systemImageType = "google_apis_playstore";
    androidEmulatorFlags = "-no-window";
  }}/bin/run-test-emulator & :
  echo "Started android emulator. PID: $!"

  ${builtins.readFile ../scripts/wait-for-boot.sh}
  ${builtins.readFile ../scripts/setup-scrcpy.sh}
  ${builtins.readFile ../scripts/start-ffmpeg.sh}
''
