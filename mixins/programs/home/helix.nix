{
  programs.helix = {
    enable = true;      
    defaultEditor = true;
    
    settings = {
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
        "A-h" = ":bprev";
        "A-l" = ":bnext";
      };
    };
  };
}
