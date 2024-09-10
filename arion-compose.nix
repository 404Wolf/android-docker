{pkgs, lib, ...}: {
  project.name = "android-docker";
  services = {
    android = {
      service = {
        privileged = true;
        devices = [
          "/dev/kvm:/dev/kvm"
        ];
      };
      build.image = lib.mkForce (pkgs.callPackage ./package/docker.nix {});
    };
  };
}
