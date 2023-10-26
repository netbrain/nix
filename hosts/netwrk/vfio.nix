{ pkgs, ... }:
{

  boot = {
    initrd.kernelModules = [
      "vfio_virqfd"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];

    kernelModules = [
      "kvm"
      "kvm_intel"
    ];

    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
      "kvm.ignore_msrs=1"
      # not using passthrough, vgpu instead
      #"vfio-pci.ids=10de:1f95"
      "blacklist=nouveau"
    ];

    kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "k9WLavAHpfRN0mgx/zEHB96xq5OAxRNqU0KH6z/d/Ks=";
        };
        version = "6.1.47";
        modDirVersion = "6.1.47";
      };
    });

    extraModprobeConfig = "options kvm_intel nested=1";
 };

  hardware.opengl.enable = true;

}
