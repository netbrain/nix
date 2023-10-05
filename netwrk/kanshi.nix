{
  home-manager.users.netbrain.services.kanshi = {
    enable = true;
    profiles = {
      internal = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.0;
          }
        ];
      };
      external = {
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
