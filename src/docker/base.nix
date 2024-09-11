{
  buildEnv,
  busybox,
  bash,
  dockerTools,
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
    ];
  };
}
