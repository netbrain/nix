{pkgs, ...}:
{
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file = {
      "zwift.sh" = {
        source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/netbrain/zwift/master/zwift.sh";
            hash = "sha256-cymIMo5bhqEXSoKKmRXyJbAksjXWJYZ6jS/AktwJt28=";
        };
        target = ".local/bin/zwift";
        executable = true;
      };
    };
}
