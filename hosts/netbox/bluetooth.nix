{ pkgs, ... }:
{
  # bluetooth
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.seat-monitoring" = "disabled";
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
    # Reconnect trusted devices when the adapter comes up
    Policy = {
      AutoEnable = true;
    };
  };
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Keep the trusted headset (Nikabe S1) connected. The old xinitrc loop only
  # tried once per session and broke on first success, so turning the headset on
  # mid-session (or after it idled out) left it disconnected. This runs
  # independently of the X session and reconnects whenever it drops.
  systemd.services.bt-headset-autoconnect = {
    description = "Keep the Nikabe S1 bluetooth headset connected";
    after = [ "bluetooth.target" ];
    wants = [ "bluetooth.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 15;
    };
    script = ''
      mac=41:42:C4:33:F3:8A
      while true; do
        if ! ${pkgs.bluez}/bin/bluetoothctl info "$mac" | grep -q "Connected: yes"; then
          ${pkgs.bluez}/bin/bluetoothctl connect "$mac" || true
        fi
        sleep 15
      done
    '';
  };
}
