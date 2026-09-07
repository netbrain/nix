{ config, pkgs, lib, ... }:
let
  # nvidia legacy_390 ships the monolithic X GLX module as "libglx.so.390.157"
  # with no unversioned "libglx.so" symlink, and provides no glvnd server-side
  # GLX (libglxserver_nvidia). On xorg-server 21.1 the server therefore loads
  # X.Org's own libglx.so, NVIDIA(0) reports "Failed to initialize the GLX
  # module", and GLX falls back to DRISWRAST (llvmpipe) — so everything, host
  # and containers, renders in software. Ship a module dir that provides the
  # unversioned name and prepend it to the X ModulePath so nvidia's GLX wins.
  nvidiaGlxCompat = pkgs.runCommand "nvidia-glx-compat" { } ''
    mkdir -p $out/lib/xorg/modules/extensions
    ln -s "$(ls ${config.hardware.nvidia.package.bin}/lib/xorg/modules/extensions/libglx.so.*)" \
      $out/lib/xorg/modules/extensions/libglx.so
  '';
in
{
  nixpkgs.config.nvidia.acceptLicense = true;

  services.xserver.modules = lib.mkBefore [ nvidiaGlxCompat ];

  # legacy_390 is marked broken for kernel >= 6.18; 6.12 is LTS and has a
  # working AUR patch in nixpkgs
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  hardware.graphics.enable32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = false; #true
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

  # CDI only injects the 64-bit driver. Zwift runs as a 32-bit Windows app
  # under wine, so without the 32-bit nvidia GL libs its OpenGL falls back to
  # the mesa/llvmpipe software renderer and the game is unusably slow. Mount
  # the 32-bit driver into /usr/local/lib/i386-linux-gnu (already in the
  # container's ld.so.conf.d, so the CDI ldcache hook indexes it).
  hardware.nvidia-container-toolkit.mounts = [{
    hostPath = "${config.hardware.nvidia.package.lib32}/lib";
    containerPath = "/usr/local/lib/i386-linux-gnu";
  }];

  services.xserver.videoDrivers = [ "nvidia" ];

}
