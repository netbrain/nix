{ pkgs, lib, ... }:
let
  # GOTOOLCHAIN=auto laster ned go1.27 for moduler som krever det, men gofmt/gopls/
  # goimports/delve på PATH er statiske Nix-binærer som linker inn parser, type-checker
  # og runtime fra den Go-en de ble bygget med. Uten denne pinnen feiler de på 1.27-
  # syntaks, f.eks. typeparametre på metoder ("method must have no type parameters").
  #
  # MERK: gopls tar normalt buildGoLatestModule nettopp for aldri å bygges mot en eldre
  # Go enn den kjører mot. Overriden her erstatter den garantien med en hard pin, så
  # denne linja må heves ved hver Go-major-bump (1.28 osv.) eller gopls henger etter.
  #
  # TODO: pkgs.go var 1.26.5 og pkgs.go_1_27 var 1.27rc2 da dette ble skrevet (2026-09-13).
  # Sjekk `nix eval .#nixosConfigurations.netmiles.pkgs.go.version` etter flake-oppdatering:
  # når default `go` er 1.27.0 eller nyere, fjern let-blokka og overridene og gå tilbake
  # til [ go gopls (lib.lowPrio gotools) delve ].
  go = pkgs.go_1_27;
  buildGoModule = pkgs.buildGoModule.override { inherit go; };
in
{
  home.packages = [
    go
    (pkgs.gopls.override { buildGoLatestModule = buildGoModule; })
    (lib.lowPrio (pkgs.gotools.override { inherit buildGoModule go; }))
    (pkgs.delve.override { inherit buildGoModule; })
  ];

  home.sessionPath = [ "$HOME/go/bin" ];
}
