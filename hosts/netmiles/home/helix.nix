{ pkgs, ... }:
{
  programs.helix = { 
    extraPackages = with pkgs; [
	    gopls 						                        # golang
      delve                                     # golang debugger
	    nodePackages.bash-language-server		      # bash
	    nodePackages.typescript-language-server		# typescript
	    yaml-language-server				              # yaml
	    jdt-language-server				                # java
	    nodePackages.vscode-json-languageserver		# json
	    nil						                            # nix
	    marksman					                        # markdown
      omnisharp-roslyn                          # c-sharp
      netcoredbg                                # c-sharp dbg
      templ                                     # templ
      vscode-langservers-extracted              # html, css, json, eslint
      dockerfile-language-server                # dockerfile
      omnisharp-roslyn                          # c-sharp
      taplo                                     # toml
      python313Packages.python-lsp-server       # python
      python313Packages.python-lsp-ruff
      python313Packages.jedi-language-server
      ty
      ruff
    ];
  };
}
