{
  ffmpeg,
  dockerTools,
  writeShellApplication,
  callPackage,
  buildEnv,
  busybox,
  scrcpy-video-port,
  scrcpy-audio-port,
  scrcpy-data-port,
  scrcpy-server,
  adb-port,
  emulator-args,
  android-composition,
  ...
}: let
  run-android-streamer = writeShellApplication {
    name = "run-android-streamer";
    runtimeInputs = [
      android-composition.androidsdk
      busybox
      ffmpeg
    ];
    text = ''
      SCRCPY_STATUS_FILE=$(mktemp)
      ${builtins.readFile ../scripts/setup-scrcpy.sh} ${scrcpy-video-port} > SCRCPY_STATUS_FILE &

      while ! grep -q ".*\[.*\]" <(tac "$SCRCPY_STATUS_FILE" | head -n1); do
        sleep 1
      done

      ${builtins.readFile ../scripts/start-ffmpeg.sh}
    '';
  };
in
  dockerTools.buildImage {
    fromImage = callPackage ./emulator.nix {
      inherit
        adb-port
        android-composition
        emulator-args
        ;
    };
    name = "AndroidStreamer";
    tag = "latest";

    config = {
      Env = [
        "SCRCPY_SERVER_PATH=${scrcpy-server}/server-debug.apk"
      ];
      EXPOSE = [
        scrcpy-video-port
        scrcpy-audio-port
        scrcpy-data-port
      ];
    };
    copyToRoot = buildEnv {
      name = "root";
      pathsToLink = ["/bin"];
      paths = [
        run-android-streamer
      ];
    };
  }
