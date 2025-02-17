{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/wwn-0x5e83a97b603dfd30";
        type = "disk";
        content = {
          type = "gpt"; 
          partitions = {
            MBR = {
              type = "EF02";
              size = "1M";
              priority = 1;
            };
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
