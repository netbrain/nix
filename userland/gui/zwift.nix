{pkgs, ...}:
{
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file = {
      "zwift.sh" = {
        source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/netbrain/zwift/master/zwift.sh";
            hash = "sha256-joipzHtLvy+l4H+NOLTSpVf8bzVGUF4JVDcyfQIt5II=";
        };
        target = ".local/bin/zwift";
        executable = true;
      };
    };
}
