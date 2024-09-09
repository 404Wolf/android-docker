{pkgs, ...}: {
  project.name = "android-docker";
  services = {
    android = {
      service = {
        image = pkgs.callPackage ./package/docker.nix {};
        privileged = true;
        devices = [
          "/dev/kvm:/dev/kvm"
        ];
      };
    };
  };
}
