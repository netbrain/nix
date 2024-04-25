{pkgs, ...}:
{
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file = {
      "zwift.sh" = {
        source = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/netbrain/zwift/master/zwift.sh";
            hash = "sha256-RA94NjRJU3EIK25ZMbCYriQeb9wsidTR8YvEBIWl0UY=";
        };
        target = ".local/bin/zwift";
        executable = true;
      };
    };
}
