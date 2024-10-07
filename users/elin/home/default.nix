{ pkgs, ... }:

{

  imports = [ 
     
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "elin";
    homeDirectory = "/home/elin";
    stateVersion = "24.05";
  };

  home.packages = with pkgs; [
    
  ];

}
