{
  pkgs,
  android-composition,
  ...
}:
pkgs.dockerTools.buildImage {
  name = "AndroidBase";

  copyToRoot = pkgs.buildEnv {
    name = "root";
    pathsToLink = ["/bin"];
    paths = [
      pkgs.coreutils
      pkgs.busybox
      pkgs.bash
      pkgs.ffmpeg
      android-composition.androidsdk
    ];
  };
}
