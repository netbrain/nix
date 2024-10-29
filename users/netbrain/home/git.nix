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
      cp = "cherry-pick";
    };
    extraConfig = {
      #url."git@github.com:netbrain".insteadOf = [ "https://github.com/netbrain" ];
      url."git@github.com:".insteadOf = [ "gh:" "github:" ];
      push.autoSetupRemote = true;
      core.editor = "hx";
    };
    includes = [{
      path = "~/.gitconfig-lyse";
      condition = "gitdir:~/dev/lyse/";
    }];
  };

  home.file.".gitconfig-lyse" = {
    text = ''
      [user]
      name = Kim Eik
      email = kim.eik@lyse.no
    '';
  };
}
