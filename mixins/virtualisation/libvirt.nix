{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      runAsRoot = false;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  systemd.services.libvirtd.path = [ pkgs.mdevctl ];

  # Virt-manager
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
    win-virtio
    virtiofsd
    looking-glass-client
    swtpm
  ];

    # Group
  users.users.netbrain.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
}
