{ pkgs, ... }:
{
  # podman is enabled by the zwift module; nvidia access is provided by
  # hardware.nvidia-container-toolkit (see nvidia.nix)
  virtualisation.podman.enable = true;

  # Rootless podman 5.x with --userns keep-id (used by the zwift wrapper for
  # volume access) falls back to chown-copying image layers on native overlay,
  # which fails: "creating an ID-mapped copy of layer ... chown: permission
  # denied". fuse-overlayfs does the idmap in userspace and avoids the copy.
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay";
      options.mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
    };
  };

  environment.systemPackages = [ pkgs.fuse-overlayfs ];
}
