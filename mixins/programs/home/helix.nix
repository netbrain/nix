{
  programs.helix = {
    enable = true;      
    defaultEditor = true;
    #languages = {
    #  language-server.jdtls = with pkgs; {
    #    command = "${jdt-language-server}/bin/jdt-language-server";
    #    args = ["-data" "/tmp"];
    #  };
    #};
    
    settings = {
      # theme = "gruvbox";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
        };
        bufferline = "multiple";
        rulers = [80];
        shell = ["bash" "-c"];       
      };
      keys.normal = {
        space.space = "file_picker";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };
}
