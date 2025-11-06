{ config, pkgs, ... }:

{
  sops.secrets = {
    "ssh/lyse_private_key" = {
      path = "${config.home.homeDirectory}/.ssh/id_ed25519_lyse";
      mode = "0600";
    };
  };

  # Regenerate public key from private key on activation
  home.activation.regenerateSshPublicKeys = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f "${config.home.homeDirectory}/.ssh/id_ed25519_lyse" ]; then
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -y -f "${config.home.homeDirectory}/.ssh/id_ed25519_lyse" > "${config.home.homeDirectory}/.ssh/id_ed25519_lyse.pub"
      $DRY_RUN_CMD chmod 644 "${config.home.homeDirectory}/.ssh/id_ed25519_lyse.pub"
    fi
  '';
}
