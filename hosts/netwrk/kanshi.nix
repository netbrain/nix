{
  home-manager.users.netbrain.services.kanshi = {
    enable = true;
    settings = {
      default = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.0;
            mode = "3840x2400@60";
          }
        ];
      };
      docked1 = {
        outputs = [
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
      };
       docked2 = {
        outputs = [
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
      };
       docked3 = {
        outputs = [
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
      };
    };
  };
}
