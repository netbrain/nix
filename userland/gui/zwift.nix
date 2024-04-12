{pkgs, ...}:
{
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file = {
      "zwift.sh" = {
        source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/netbrain/zwift/master/zwift.sh";
            hash = "sha256-RQJ6gPHXiY8CNeGGgQDnwG3mHzmMo3Yl6Ninnx+mJNY=";
        };
        target = ".local/bin/zwift";
        executable = true;
      };
    };
}
