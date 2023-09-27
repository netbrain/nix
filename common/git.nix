{
  programs.git = {
    enable = true;
    difftastic = {
      enable = true;
      background = "dark";
    };
    userName = "Kim Eik";
    userEmail = "kim@heldig.org";
    aliases = {
      co = "checkout";
    };
    extraConfig = {
      url."git@github.com:".insteadOf = [ "gh:" "github:" "https://github.com" ];
      push.autoSetupRemote = true;
    };
  };
}
