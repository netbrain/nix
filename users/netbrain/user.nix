{ pkgs, ... }:

{
  users = {
    mutableUsers = false;
    users = {
      netbrain = {
        description = "Kim";
        extraGroups = [ 
          "audio" 
          "docker" 
          "video" 
          "wheel"
          "input"
          "netbrain" 
        ];
        shell = pkgs.bash;
        home = "/home/netbrain";
        isNormalUser = true;
        uid = 1000;
        hashedPassword = "$6$Fcid4G0MHoD/OIQg$1xyt96zKWBwyfja14oAV6WJnL0iiLJhnVnL91syvH1tUIXQD3MZixnIgurUuqiuA4cQKetPs9kMRXLLuz1klW0";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuYnieATL5o4WCdGUA+NvZ36rcWasKoQ0wUAsJiHSf95mRmy4ceG1p1LO+VQ4YnXFnApokejIwNnGYAge00dZ3Fl3d1LsjegnigD6/w0GdrmxhfL4UzhRw6nFJGVtw5oiVfcJap1nl9iCtUAsqKuzPA7itR0YfHwsu06AyIVf9h8viL8cYidx5SBHiugywLT/wBSOGLqjvCIvyXHn1PiYSrP9GzLMpfh4cx8YclsaJACWjjt20j7InecVVDULQrYRZnQxZWJrNWtWbSLcWBUjFktN4piSw19xZd9L7SqcONeAeIayA0GowE7eR6pX0HtH5GUNzloQsNq5JOPmJbz+D netbrain"
        ];
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
