{
  services = {
    syncthing = {
      enable = true;
      tray =  {
        enable = false;
      };
      #user = "netbrain";
      #dataDir = "/home/netbrain/sync";    # Default folder for new synced folders
      #configDir = "/home/netbrain/.config/syncthing";   # Folder for Syncthing's settings and keys
      #overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      #overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    };
  };
}
