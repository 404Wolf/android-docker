{
  busybox,
  ffmpeg,
  writeShellApplication,
  android-composition,
  scrcpy-video-port ? "6000",
  scrcpy-audio-port ? "6001",
  scrcpy-data-port ? "6002",
  rtp-video-port ? "5000",
  rtp-audio-port ? "5001",
}:
writeShellApplication {
  name = "run-android-streamer";
  runtimeInputs = [
    android-composition.androidsdk
    busybox
    ffmpeg
  ];
  text = ''
    ${builtins.readFile ../scripts/start-scrcpy.sh}
    ${builtins.readFile ../scripts/start-ffmpeg.sh}

    start_scrcpy ${scrcpy-video-port} > SCRCPY_STATUS_FILE &
  '';
}
