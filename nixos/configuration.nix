{ pkgs, inputs, config, projects, ... }:
{
  environment.variables = {
    DOCKER_HOST = "unix:///run/podman/podman.sock";
  };

  environment.systemPackages = [
    pkgs.arion
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    arion = {
      inherit projects;
      backend = "podman-socket";
      # projects.minecraft.settings = {
      #   imports = [ inputs.minecraft-arion.arion-module ];
      # };
    };
  };
}