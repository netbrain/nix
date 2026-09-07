{ inputs, pkgs, lib, config, ... }:

let
  z = config.programs.zwift;

  # Two local patches to upstream zwift.sh (both filed upstream):
  #
  # 1. It forces "--privileged --security-opt label=disable" on any non-SELinux
  #    host. Under rootless podman 5.x that breaks container startup (privileged
  #    makes podman mount a fresh devpts and create /dev device nodes, both fail
  #    with EINVAL/EPERM in a rootless userns). The GPU is provided via CDI
  #    (--device=nvidia.com/gpu=all), so privileged is unnecessary; strip it.
  #
  # 2. It derives the container name, data volume and rider config file from
  #    $USER. Our kiosk logs in one OS user (netbrain) and picks a rider per
  #    session, but overriding $USER to a name with no passwd entry makes crun
  #    fail (getpwnam -> bad group setup -> the devpts mount errors out). So key
  #    those names off ${ZWIFT_RIDER:-$USER} instead, leaving $USER as the real
  #    login user for podman's rootless resolution.
  #
  # --group-add keep-groups (added below) lets crun set the container user's
  # supplementary groups. These are podman 4.x -> 5.x behaviour changes.
  patchedZwiftSh = pkgs.runCommand "zwift-patched.sh" { } ''
    sed -e 's/--privileged --security-opt label=disable/--security-opt label=disable/g' \
        -e 's/zwift-''${USER}/zwift-''${ZWIFT_RIDER:-''${USER}}/g' \
        -e 's/''${USER}-config/''${ZWIFT_RIDER:-''${USER}}-config/g' \
        -e 's/''${USER}-graphics/''${ZWIFT_RIDER:-''${USER}}-graphics/g' \
        ${inputs.zwift}/src/zwift.sh > $out
  '';

  # Read the per-host programs.zwift.* options (set in each host's config) and
  # feed them to the patched script via env, mirroring what the module's own
  # wrapper does. Username/password still come from ~/.config/zwift/config.
  zwiftFixed = pkgs.writeShellScriptBin "zwift" ''
    export CONTAINER_TOOL="${z.containerTool}"
    export CONTAINER_EXTRA_ARGS="--group-add keep-groups ${z.containerExtraArgs}"
    ${lib.optionalString z.zwiftFg "export ZWIFT_FG=1"}
    ${lib.optionalString z.zwiftOverrideGraphics "export ZWIFT_OVERRIDE_GRAPHICS=1"}
    ${lib.optionalString (z.zwiftOverrideResolution != "")
      "export ZWIFT_OVERRIDE_RESOLUTION='${z.zwiftOverrideResolution}'"}
    exec ${pkgs.bash}/bin/bash ${patchedZwiftSh} "$@"
  '';
in
{
  # The module still sets up rootless podman and the programs.zwift option
  # surface; we shadow its wrapper binary with the patched one (hiPrio wins the
  # bin/zwift collision in environment.systemPackages).
  programs.zwift.enable = true;
  environment.systemPackages = [ (lib.hiPrio zwiftFixed) ];

  # Zwift Companion / device pairing, per netbrain/zwift docs
  networking.firewall = {
    allowedUDPPorts = [ 3022 3024 ];
    allowedTCPPorts = [ 21587 21588 ];
  };
}
