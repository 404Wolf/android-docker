{
  pkgs,
  scrcpy-server,
  android-composition,
  ...
}:
pkgs.dockerTools.buildImage {
  name = "AndroidRunner";
  tag = "latest";
  fromImage = pkgs.callPackage ./streaming.nix {
    inherit scrcpy-server android-composition;
    scrcpy-video-port = "6000";
    scrcpy-audio-port = "6001";
    scrcpy-data-port = "6002";
    adb-port = "5005";
    emulator-port = "5004";
    emulator-args = {
      name = "android-emulator";
      abiVersion = "x86_64";
      platformVersion = "33";
      systemImageType = "google_apis_playstore";
      androidEmulatorFlags = "-no-window -no-metrics";
    };
  };
  config = {
    Cmd = ["run-android-emulator && run-android-streamer"];
  };
}
