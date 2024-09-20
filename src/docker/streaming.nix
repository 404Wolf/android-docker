{
  dockerTools,
  callPackage,
  buildEnv,
  scripts,
  scrcpy-video-port,
  scrcpy-audio-port,
  scrcpy-data-port,
  scrcpy-server,
  adb-port,
  emulator-args,
  android-composition,
  ...
}:
dockerTools.buildImage {
  fromImage = callPackage ./emulator.nix {
    inherit
      scripts
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
      scripts.start-scrcpy
      scripts.start-ffmpeg
    ];
  };
}
