{pkgs}: let
  run-android-emulator = (import ./utils/emulator.nix) {inherit pkgs;};
in
  pkgs.writeShellScriptBin "run-emulator" "${run-android-emulator}/bin/android-emulator"
