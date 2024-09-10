{
  pkgs,
  scrcpy-video-port,
  scrcpy-audio-port,
  scrcpy-data-port,
  adb-port,
  emulator-port,
  emulator-args,
  android-composition,
  scrcpy-server,
  ...
}: let
  run-android-streamer = pkgs.writeShellScriptBin "run-android-streamer" ''
    ${builtins.readFile ../scripts/setup-scrcpy.sh} ${scrcpy-video-port} & :
    sleep 2
    ${builtins.readFile ../scripts/start-ffmpeg.sh}
  '';
in
  pkgs.dockerTools.buildImage {
    fromImage = pkgs.callPackage ./emulator.nix {
      inherit
        adb-port
        android-composition
        emulator-port
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
      copyToRoot = pkgs.buildEnv {
        name = "root";
        pathsToLink = ["/bin"];
        paths = [
          run-android-streamer
        ];
      };
    };
  }
