{pkgs}:
let
  run-android-emulator = (import ./utils/emulator.nix) {inherit pkgs;};
  android-composition = (import ./utils/composition.nix) {inherit pkgs;};
  android-sdk = android-composition.androidsdk;
in
pkgs.writeShellScriptBin "run-emulator" ''
${run-android-emulator}
''
