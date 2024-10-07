{ lib, ... }:
{
  users.users = {
    netbrain = {
      extraGroups = [ 
        "tty" 
      ];
      hashedPassword = lib.mkForce ""; # passwordless
    };
    elin = {
      extraGroups = [ 
        "tty"
      ];
      hashedPassword = lib.mkForce ""; #passwordless
    };
  };
}
