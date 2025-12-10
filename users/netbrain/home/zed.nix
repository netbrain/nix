{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [ "nix" "yaml" "html" "json" ];

    userSettings = {
      hour_format = "hour24";
      auto_update = false;

      vim_mode = false;
      base_keymap = "JetBrains";

      # Tell Zed to use direnv and direnv can use a flake.nix environment
      load_direnv = "shell_hook";

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      terminal = {
        dock = "bottom";
        shell = "system";
        line_height = "comfortable";
        working_directory = "current_project_directory";
        env = {
          TERM = "alacritty";
        };
      };

      show_whitespaces = "all";

      lsp = {
        # Nix
        nix = {
          binary = {
            path_lookup = true;
          };
        };

        # Go
        gopls = {
          binary = {
            path_lookup = true;
          };
        };

        # Java
        jdtls = {
          binary = {
            path_lookup = true;
          };
        };

        # TypeScript/JavaScript
        typescript-language-server = {
          binary = {
            path_lookup = true;
          };
        };

        # HTML
        vscode-html-language-server = {
          binary = {
            path_lookup = true;
          };
        };

        # CSS
        vscode-css-language-server = {
          binary = {
            path_lookup = true;
          };
        };

        # JSON
        vscode-json-language-server = {
          binary = {
            path_lookup = true;
          };
        };

        # YAML
        yaml-language-server = {
          binary = {
            path = lib.getExe pkgs.yaml-language-server;
          };
          settings = {
            yaml = {
              format = {
                enable = true;
              };
              validation = false;
            };
          };
        };
      };

      languages = {
        YAML = {
          format_on_save = "on";
          formatter = {
            external = {
              command = lib.getExe pkgs.yamlfmt;
              arguments = [ "-in" ];
            };
          };
        };
      };
    };
  };
}
