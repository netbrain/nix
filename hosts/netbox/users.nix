{ lib, ... }:
{
  users.users = {
    netbrain = {
      extraGroups = [
        "tty"
      ];
      hashedPassword = lib.mkForce ""; # passwordless
    };
  };
}
