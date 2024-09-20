{
  callPackage,
  dockerTools,
  android-composition,
  emulator-args,
  scripts,
}:
dockerTools.buildImage {
  name = "AndroidRunner";
  tag = "latest";
  fromImage = callPackage ./emulator.nix {
    inherit scripts emulator-args android-composition;
  };
  config = {
    Cmd = ["run-android-emulator"];
  };
}
