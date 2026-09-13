# harness-remote: lokal kontrollplan for AI-kodeagent-sesjoner (Claude Code,
# Codex, OpenCode, OMP, PI), styrt fra desktop, Android eller web.
#
# Kun bridge-delen ("launcher"/daemon) pakkes. web/ er en separat
# Vite/React/Electron/Capacitor-app som upstream kjører som dev-server; bruk
# den hostede klienten på https://giuliastro.github.io/harness-remote/ og
# start launcheren med --cors https://giuliastro.github.io.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "harness-remote";
  # Taggen er eneste ærlige versjonsnummer: package.json i treet er utdatert
  # (root sier 0.1.0, bridge/ sier 0.1.7) mens releasene er v3.x.
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "giuliastro";
    repo = "harness-remote";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mgw53rDzBDxaOIhsYtzB5IC/B6J6KfvQNm89qHClYek=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # bridge/src importerer kun node:-stdlib og relative stier (null eksterne
  # avhengigheter), så kilden kopieres som den er. bridge/package.json MÅ ligge
  # over src/: den har "type": "module", og uten den tolker node .js-filene som
  # CommonJS og launcher.js feiler på import-setningene.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/harness-remote
    cp -r bridge $out/lib/harness-remote/

    # Agent-CLI-ene (claude, codex, opencode) slås opp på PATH ved kjøring og
    # pinnes bevisst ikke her, slik at brukerens egne installasjoner gjelder og
    # man ikke ender med to versjoner av samme agent på maskinen.
    makeWrapper ${lib.getExe nodejs} $out/bin/harness-remote \
      --add-flags "$out/lib/harness-remote/bridge/src/launcher.js"

    makeWrapper ${lib.getExe nodejs} $out/bin/harness-remote-daemon \
      --add-flags "$out/lib/harness-remote/bridge/src/daemon-cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Local-first control plane for native AI coding-agent sessions";
    homepage = "https://github.com/giuliastro/harness-remote";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    mainProgram = "harness-remote";
  };
})
