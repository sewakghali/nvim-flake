{
  description = "Portable Neovim and Terminal Environment Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # neovim
        nvimDeps = with pkgs; [
          ripgrep
          fd
          git
          stylua
          lua-language-server
          nil
          tree-sitter
          nodejs_24
        ];

        # environment
        shellDeps = with pkgs; [
          zellij
          zsh
        ];

        # wrapped nvim
        myNvim = pkgs.symlinkJoin {
          name = "nvim-flake";
          paths = [ pkgs.neovim ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath nvimDeps} \
              --set-default XDG_CONFIG_HOME "${./.}" \
              --set-default XDG_DATA_HOME "$HOME/.local/share/nvim-global-data"
          '';
        };
      in
      {
        packages.default = myNvim;
        
        packages.everything = pkgs.symlinkJoin {
          name = "my-total-env";
          paths = [ myNvim pkgs.zellij pkgs.zsh ];
        };

        devShells.default = pkgs.mkShell {
          packages = nvimDeps ++ shellDeps;

          shellHook = ''
            export SHELL="${pkgs.zsh}/bin/zsh"
            export ZELLIJ_CONFIG_FILE="${./.}/zellij/config.kdl"

            # Uses project-local config if an 'nvim' folder exists, 
            # otherwise uses the wrapped flake version.
            nvim() {
              if [ -d "./nvim" ]; then
                echo "--- Using project-local Neovim config ---" >&2
                XDG_CONFIG_HOME="$PWD" \
                XDG_DATA_HOME="$HOME/.local/share/nvim-project-data" \
                ${pkgs.neovim}/bin/nvim "$@"
              else
                ${myNvim}/bin/nvim "$@"
              fi
            }
          '';
        };
      }
    );
}