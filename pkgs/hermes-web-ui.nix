# hermes-web-ui (Ekko Studio): lokalt AI-arbeidsrom for multi-agent-chat,
# koding og visuelle arbeidsflyter. Serverer et web-UI på port 8648.
#
# Kjøres via npx på samme måte som npm-package-flaket, men med eget miljø.
# npm-package kan ikke brukes her av to grunner:
#   1. Flaket pinner node 22, mens pakken krever node >= 23 (EBADENGINE, exit 1).
#   2. Avhengigheten node-pty har ingen prebuild for denne node-ABI-en og må
#      bygges med node-gyp, som trenger python3 og en C-toolchain på PATH.
#
# ADVARSEL: serveren binder hardkodet 0.0.0.0 og har ingen flagg eller
# env-variabel for bind-adresse (dist/server/index.js defaulter til "0.0.0.0"
# og leser ingen host fra miljøet). Den kringkaster i tillegg sin egen
# tilstedeværelse over UDP på LAN. Default-innlogging er admin/123456.
# Bytt passord ved første innlogging, og ikke åpne 8648 i brannmuren.
#
# Lisensen er BSL-1.1, altså ikke fri programvare. Den slipper gjennom fordi
# nixpkgs.config.allowUnfreePredicate er satt til (_: true) i home.nix.
{
  lib,
  writeShellScriptBin,
  nodejs,
  python3,
  gcc,
  gnumake,
}:

let
  # Pinnet fordi npx ellers henter ny versjon ved hver kjøring og kan trigge et
  # nytt node-gyp-bygg. 0.7.21 er versjonen som er verifisert på denne maskinen.
  version = "0.7.21";
in
writeShellScriptBin "hermes-web-ui" ''
  export npm_config_loglevel=error

  # node-gyp trenger python3 + cc + make for å bygge node-pty.
  export PATH="${lib.makeBinPath [ nodejs python3 gcc gnumake ]}:$PATH"

  exec ${lib.getExe' nodejs "npx"} --yes hermes-web-ui@${version} "$@"
''
