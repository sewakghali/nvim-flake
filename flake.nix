{
  description = "Portable Neovim flake with a clean, wrapper-less devShell.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nvimRuntimeDeps = with pkgs; [
          neovim
          ripgrep
          fd
          git
          stylua
          lua-language-server
          nil
        ];

        nvimConfigPath = "/share/nvim";

        # This wrapper simply executes the neovim binary, relying on Nix's environment
        # mechanism for XDG_CONFIG_HOME and PATH inheritance.
        simpleNvimWrapper = pkgs.writeScriptBin "nvim" "exec ${pkgs.neovim}/bin/nvim \"\$@\"";

        myNvim = pkgs.stdenv.mkDerivation {
          pname = "nvim-flake";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./.;
          buildInputs = [ simpleNvimWrapper ];

          env = {
            # Directs Neovim to look for config in the immutable store path.
            XDG_CONFIG_HOME = "$out/share";
            # Sets data directory outside of the Nix store for cache and plugins.
            XDG_DATA_HOME = "$HOME/.local/share/nvim-global-data";
            # Sets PATH so LSPs, formatters, and tools are available to Neovim.
            PATH = pkgs.lib.makeBinPath nvimRuntimeDeps;
          };

          installPhase = ''
            mkdir -p $out/bin $out${nvimConfigPath}
            # Copy the nvim config directory from the source subdirectory
            cp -r $src/nvim/* $out${nvimConfigPath}/
            cp ${simpleNvimWrapper}/bin/nvim $out/bin/
          '';
        };
      in
      {
        packages.default = myNvim;
        apps.nvim = {
          type = "app";
          program = "${myNvim}/bin/nvim";
        };

        devShells.default = pkgs.mkShell {
          packages = nvimRuntimeDeps;

          shellHook = ''
            NIX_CONFIG_PATH="${myNvim}/share"

            # This function runs every time 'nvim' is called in the shell.
            nvim() {
              if [ -d "./nvim" ]; then
                echo "Using project-local Neovim config: ./nvim" >&2
                # Using built-in $PWD for the current directory
                XDG_CONFIG_HOME="$PWD" XDG_DATA_HOME="$HOME/.local/share/nvim-project-data" ${pkgs.neovim}/bin/nvim "$@"
              else
                echo "Using flake's immutable config: $NIX_CONFIG_PATH/nvim" >&2
                # Use the immutable flake config
                XDG_CONFIG_HOME="$NIX_CONFIG_PATH" XDG_DATA_HOME="$HOME/.local/share/nvim-project-data" ${pkgs.neovim}/bin/nvim "$@"
              fi
            }
          '';
        };
      }
    );
}
