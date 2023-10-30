{ pkgs, ... }:
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
      url."git@github.com:netbrain".insteadOf = [ "https://github.com/netbrain" ];
      url."git@github.com:".insteadOf = [ "gh:" "github:" ];
      push.autoSetupRemote = true;
    };
    includes = [{
      path = "~/.gitconfig-altibox";
      condition = "gitdir:~/dev/altibox/";
    }];
  };

  home.file.".gitconfig-altibox" = {
    text = ''
      [user]
      name = Kim Eik
      email = kim.eik@altibox.no
    '';
  };
}
