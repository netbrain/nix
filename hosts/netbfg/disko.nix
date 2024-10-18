{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-eui.0026b7683f7a2575";
        type = "disk";
        content = {
          type = "gpt"; 
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";  
                mountpoint = "/boot"; 
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";  # Use the rest of the space for root
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
