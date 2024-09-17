{
  home-manager.users.netbrain.services.kanshi = {
    enable = true;
    settings = [
    {
      profile.name = "default";
      profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
            mode = "1920x1200@60";
          }
        ];
    }
      
    {
      profile.name = "docked1";
      profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            status = "enable";
            scale = 1.0;
            mode = "3840x2160@60";
          }
        ];
    }
    ];
  };
}
