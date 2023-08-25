{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        syntax-theme = "none";
      };
    };
    userName = "Kim Eik";
    userEmail = "kim@heldig.org";
    aliases = {
      co = "checkout";
    };
    extraConfig = {
      url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    };
  };
}
