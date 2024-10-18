{ pkgs, ... }:

{
  
  environment.systemPackages = with pkgs; [
    (pkgs.stdenv.mkDerivation {
      name = "zwift";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/netbrain/zwift/master/zwift.sh";
        hash = "sha256-oNo2dOw3R/pd3IhVbT2AbG709SUIHaqbkTTJ57vO56c=";
      };
      buildInputs = [ pkgs.bash ];
      unpackPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/zwift
      '';
      dontPatchShebangs = true;
      installPhase = ''
        chmod +x $out/bin/zwift
      '';
    })
  ];

}
