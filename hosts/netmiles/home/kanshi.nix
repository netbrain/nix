{
  services.kanshi = {
    enable = true;
    systemdTarget = "river-session.target";
    settings = [
    {
      profile.name = "default";
      profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
            mode = "1920x1200@60";
            position = "0,0";
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
            scale = 1.25;
            mode = "3840x2160@60";
            position = "0,0";
          }
        ];
    }
    ];
  };
}
