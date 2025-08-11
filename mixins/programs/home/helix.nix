{ pkgs, ... }:
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

    languages = {
      language-server = {
        yaml-language-server = {
          command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
          args = [ "--stdio" ];
          config.yaml.format.enable = true;
          config.yaml.validation = false;
          #config.yaml.schemas = {
          #  "https://json.schemastore.org/github-workflow.json" = ".github/{actions,workflows}/*.{yml,yaml}";
          #  "https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json" = "roles/{tasks,handlers}/*.{yml,yaml}";
          #  "kubernetes" = "{clusters,components,k8s}/*.{yml,yaml}";
          #};
        };
      };
      
     language = [
        {
          name = "yaml";
          file-types = [
            "yml"
            "yaml"
          ];
          auto-format = true;
          formatter = {
            #command = "${pkgs.nodePackages.prettier/bin/prettier}"
            #args = ["--parser" "yaml"];
            command = "${pkgs.yamlfmt}/bin/yamlfmt";
            args = [ "-in" ];
          };
          language-servers = [ "yaml-language-server" ];
        }
      ];
    };
  };
}
