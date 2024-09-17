{
  services = {
    blueman.enable = true;
    
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "no";
    };
    
    fwupd.enable = true;
  };
}
