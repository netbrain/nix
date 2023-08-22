{
  description = "NixOS + standalone home-manager config flakes to get you started!";
  outputs = inputs: {
    templates = {
      standard = {
        description = ''
          Standard flake - augmented with boilerplate for custom packages, overlays, and reusable modules.
          Perfect migration path for when you want to dive a little deeper.
        '';
        path = ./standard;
      };
    };
  };
}
