{ inputs, pkgs, ... }:

{
  imports = [
     inputs.hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    ./configuration.nix
    ./hw.nix
    ./powermgmt.nix
    ./gui.nix
    ./lyse-cert.nix
    ./lyse-docker.nix
    ./tailscale.nix
    ./browsers
    ../../mixins/networking/networkmanager.nix
    ../../mixins/virtualisation/libvirt.nix
    ../../mixins/virtualisation/docker.nix
    ../../mixins/programs/steam.nix
    ../../mixins/programs/nm-applet.nix
    ../../mixins/programs/wireshark.nix
    ../../mixins/programs/river.nix
    ../../mixins/services/greetd.nix
    ../../mixins/services/blueman.nix
    ../../mixins/services/fwupd.nix
    ../../secrets/sops.nix
    ../../secrets/lyse-secrets.nix
  ];

  services.ollama = {
    enable = true;
  };

  services.printing.enable = true;

services.printing.drivers = [
  (pkgs.writeTextDir "/share/cups/model/Munbyn.ppd"
    (builtins.readFile ./ppd/Munbyn_Label_Printer.ppd))
  (pkgs.runCommand "rastertolabel-dir" {
    buildInputs = [
      pkgs.patchelf
      pkgs.cups
      pkgs.cups-filters
      pkgs.stdenv.cc
    ];
  } ''
    mkdir -p $out/lib/cups/filter/Munbyn/Filter

    # Copy the binary and ensure it’s writable for patching
    cp ${./ppd/rastertolabel} $out/lib/cups/filter/Munbyn/Filter/rastertolabel.bin
    chmod u+w $out/lib/cups/filter/Munbyn/Filter/rastertolabel.bin

    # Patch the binary:
    patchelf --set-interpreter "$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)" \
             --set-rpath "${pkgs.cups.lib}:${pkgs.cups-filters}" \
             $out/lib/cups/filter/Munbyn/Filter/rastertolabel.bin
    chmod +x $out/lib/cups/filter/Munbyn/Filter/rastertolabel.bin

    # Create a wrapper script that also sets LD_LIBRARY_PATH at runtime
    mkdir -p $out/bin
    cat > $out/bin/rastertolabel <<EOF
#!${pkgs.stdenv.shell}
export LD_LIBRARY_PATH="${pkgs.cups.lib}/lib:${pkgs.cups-filters}"
exec "$out/lib/cups/filter/Munbyn/Filter/rastertolabel.bin" "\$@"
EOF
    chmod +x $out/bin/rastertolabel

    # Place the wrapper at the expected path
    cp $out/bin/rastertolabel $out/lib/cups/filter/Munbyn/Filter/rastertolabel
  '')
];


  hardware.printers = {
    #ensurePrinters = [
    #  {
    #    name = "Munbyn";
    #    location = "Home";
    #    deviceUri = "usb://Printer/Printer?serial=941P242115892";
    #    model = "Munbyn_Label_Printer.ppd";
    #  }
    #];
  };
}
