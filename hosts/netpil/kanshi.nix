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
            scale = 2.0;
            mode = "3840x2400@60";
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
      
    {
      profile.name ="docked2";
      profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-2";
            status = "enable";
            scale = 1.0;
            mode = "3840x2160@60";
          }
        ];
    }
    
    {
      profile.name = "docked3";
      profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-3";
            status = "enable";
            scale = 1.0;
            mode = "3840x2160@60";
          }
        ];
    }
    ];
  };
}
