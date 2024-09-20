{
  buildEnv,
  busybox,
  bash,
  dockerTools,
  android-composition,
  ...
}:
dockerTools.buildImage {
  name = "AndroidBase";
  tag = "latest";
  copyToRoot = buildEnv {
    name = "root";
    pathsToLink = ["/bin"];
    paths = [
      busybox
      bash
      (android-composition.androidsdk)
    ];
  };
}
