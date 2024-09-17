{

  hardware.openrazer = {
    enable = true;
    users = ["netbrain"];
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
