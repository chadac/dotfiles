# Enable Docker mainly for stuff that doesn't work well with podman
{ pkgs, lib, ... }: {
  boot.enableContainers = lib.mkForce true;

  environment.systemPackages = with pkgs; [ docker-compose ];

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    podman = {
      dockerCompat = lib.mkForce false;
      dockerSocket.enable = lib.mkForce false;
    };
  };

  users.extraGroups.docker.members = [ "chadac" ];
  users.users.chadac.extraGroups = [ "chadac" ];
}
