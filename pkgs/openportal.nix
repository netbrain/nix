# openportal: mobilvennlig web-UI for opencode/codex/claude.
# Kun publisert på npm (ingen flake), og tarballen er allerede ferdig bygget:
# dist/index.js er bundlet med `bun build --target bun`, og web/ er en ferdig
# Nitro-server med vendret node_modules og ingen native .node-binærer. Derfor
# holder det å pakke ut og wrappe; buildNpmPackage har ingenting å løse opp.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  bun,
  opencode,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openportal";
  version = "0.1.32";

  src = fetchurl {
    url = "https://registry.npmjs.org/openportal/-/openportal-${finalAttrs.version}.tgz";
    hash = "sha256-T/or2oyGwvKLaGSnY+gNVUY4oxcAsnd7Lm1qJ4ZgJCs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # dist/index.js finner Nitro-serveren via `join(__dirname, "..", "web", "server")`,
  # så dist/ og web/ må forbli søsken. Derfor kopieres hele treet til $out/lib og
  # bin/openportal er en wrapper, ikke en symlink til dist/index.js.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/openportal
    cp -r dist web package.json $out/lib/openportal/

    # Prosessen spawner "opencode" og "bun" fra PATH. --prefix (ikke --set) beholder
    # ambient PATH så `--provider claude` fortsatt finner claude i brukerprofilen.
    makeWrapper ${lib.getExe bun} $out/bin/openportal \
      --add-flags "$out/lib/openportal/dist/index.js" \
      --prefix PATH : ${lib.makeBinPath [ bun opencode ]}

    runHook postInstall
  '';

  meta = {
    description = "Mobile-first web UI for opencode, codex and claude";
    homepage = "https://www.openportal.space/";
    downloadPage = "https://github.com/hosenur/portal";
    license = lib.licenses.mit;
    mainProgram = "openportal";
    platforms = bun.meta.platforms;
  };
})
