{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml"; 
    age.keyFile = "/home/netbrain/.config/sops/age/keys.txt";
  };
}
