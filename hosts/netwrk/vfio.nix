{...}:
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

    extraModprobeConfig = "options kvm_intel nested=1";
 };

  hardware.opengl.enable = true;

}
