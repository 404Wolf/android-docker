{
  python3,
  androidenv,
  busybox,
  writeShellApplication,
  android-composition,
  ...
}: rec {
  start-ffmpeg = writeShellApplication {
    name = "start-ffmpeg";
    runtimeInputs = [(python3.withPackages (pyPkgs: with pyPkgs; [ffmpy]))];
    text = ''python -O ${./start-ffmpeg.py} "$@"'';
  };
  start-scrcpy = writeShellApplication {
    name = "start-scrcpy";
    runtimeInputs = [python3];
    text = ''python -O ${./start-scrcpy.py} "$@"'';
  };
  wait-for-boot = writeShellApplication {
    name = "wait-for-boot";
    runtimeInputs = [android-composition.androidsdk busybox];
    text = builtins.readFile ./wait-for-boot.sh;
  };
  handle-shutdown = writeShellApplication {
    name = "handle-shutdown";
    runtimeInputs = [busybox];
    text = builtins.readFile ./handle-shutdown.sh;
  };
  setup-environment = writeShellApplication {
    name = "setup-environment";
    runtimeInputs = [busybox];
    text = builtins.readFile ./setup-environment.sh;
  };
  run-android-emulator = {emulator-args}:
    writeShellApplication {
      name = "run-android-emulator";
      runtimeInputs = [
        busybox
        android-composition.androidsdk
        (androidenv.emulateApp emulator-args)
        wait-for-boot
        handle-shutdown
        setup-environment
      ];
      text = builtins.readFile ./run-android-emulator.sh;
    };
}
