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

  # Virt-manager
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
    win-virtio
    looking-glass-client
    swtpm
  ];

  environment.etc = {
    # Looking glass
    "tmpfiles.d/10-looking-glass.conf" = {
      mode = "0555";
      text = ''
        # Type Path               Mode UID  GID Age Argument
        f /dev/shm/looking-glass 0666 netbrain kvm -
        '';
      };
    };

  # Group
  users.users.netbrain.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
}
