{ pkgs, ... }:

{
    users = {
    mutableUsers = false;
    users = {
      netbrain = {
        description = "Kim Eik";
        extraGroups = [ 
          "audio" 
          "docker" 
          "video" 
          "wheel" 
          "netbrain" 
          "networkmanager" 
          "wireshark" 
        ];
        shell = pkgs.bash;
        home = "/home/netbrain";
        isNormalUser = true;
        uid = 1000;
        hashedPassword = "$6$Fcid4G0MHoD/OIQg$1xyt96zKWBwyfja14oAV6WJnL0iiLJhnVnL91syvH1tUIXQD3MZixnIgurUuqiuA4cQKetPs9kMRXLLuz1klW0";
      };
    };
    groups = {
      netbrain = {
        gid = 1000;
        members = [ "netbrain" ];
      };
    };
  };
}
