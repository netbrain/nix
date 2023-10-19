{ pkgs, ...}:

{
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_latest;

  virtualisation.libvirtd = {
    hooks.qemu = {
        win11-mdev = "${pkgs.writeShellScript "win11-mdev.sh" ''
          if [[ $1 == "win11" ]]
          then
          case $2 in
            prepare)
              mdevctl define -u 764d3e0f-ede8-42c9-b9b1-a866f2678039 -p 0000:01:00.0 --type nvidia-333
              mdevctl start -u 764d3e0f-ede8-42c9-b9b1-a866f2678039
            ;;
            release)
              mdevctl stop -u 764d3e0f-ede8-42c9-b9b1-a866f2678039
              mdevctl undefine -u 764d3e0f-ede8-42c9-b9b1-a866f2678039
              ;;
          esac
          fi
      ''}";
    };
  };
}
