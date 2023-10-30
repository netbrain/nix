{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
      
    defaultEditor = true;
    extraPackages = with pkgs; [
	    gopls 						                        # golang
      delve                                     # golang debugger
	    nodePackages.bash-language-server		      # bash
	    nodePackages.typescript-language-server		# typescript
      dockerfile-language-server-nodejs		      # dockerfile
	    yaml-language-server				              # yaml
	    jdt-language-server				                # java
	    nodePackages.vscode-json-languageserver		# json
	    nil						                            # nix
	    marksman					                        # markdown
      omnisharp-roslyn                          # c-sharp
      netcoredbg                                # c-sharp dbg 
    ];

    languages = {
      language-server.jdtls = with pkgs; {
        command = "${jdt-language-server}/bin/jdt-language-server";
        args = ["-data" "/tmp"];
      };
   };
    
    settings = {
      theme = "gruvbox";
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
