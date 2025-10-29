{
  description = "Portable Neovim flake with project-local override support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
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

        # Define the path to the installed Neovim config
        nvimConfigPath = "/share/nvim";

        # Create the wrapper script that handles the devcontainer-like logic
        nvimWrapper = pkgs.writeScriptBin "nvim" ''
          #!/${pkgs.runtimeShell}

          # This is the path where the user can modify the config.
          # We'll use the standard XDG_CONFIG_HOME if possible, but redirect it.
          WRITABLE_CONFIG_DIR="$HOME/.config/nvim-global"

          # Copy-on-First-Run Logic: Only copies the config if the writable one doesn't exist.
          if [ ! -d "$WRITABLE_CONFIG_DIR" ]; then
            
            # Get the Nix store path of the installed config (same logic as before)
            NIX_STORE_CONFIG_ROOT="$(${pkgs.coreutils}/bin/dirname "$(readlink -f "$0")")/.."
            NIX_CONFIG_PATH="$NIX_STORE_CONFIG_ROOT/share/nvim"
            
            echo "Initializing writable Neovim config at: $WRITABLE_CONFIG_DIR" >&2
            
            # Copy the immutable config to the writable user path
            ${pkgs.coreutils}/bin/mkdir -p "$WRITABLE_CONFIG_DIR"
            ${pkgs.coreutils}/bin/cp -r "$NIX_CONFIG_PATH" "$WRITABLE_CONFIG_DIR/"
          fi

          # --- Configuration Logic ---
          # We rely on the wrapper's local check OR the new writable config.
          if [ -d "./nvim" ]; then
            # Project-local override
            export XDG_CONFIG_HOME="$(${pkgs.coreutils}/bin/pwd)"
            echo "Using project-local Neovim config: $XDG_CONFIG_HOME/nvim" >&2
          else
            # Fallback: Use the writable copy we just ensured exists (or existed already)
            # Neovim looks for the 'nvim' directory, so we set XDG_CONFIG_HOME to the parent.
            export XDG_CONFIG_HOME="$HOME/.config" 
            echo "Using global writable Neovim config: $WRITABLE_CONFIG_DIR" >&2
          fi

          # Set the PATH for all tools (LSPs, etc.)
          export PATH="${pkgs.lib.makeBinPath nvimRuntimeDeps}:$PATH"

          # Set XDG_DATA_HOME for cache/lock files to prevent Permission Denied errors
          export XDG_DATA_HOME="$HOME/.local/share/nvim-global-data"

          exec ${pkgs.neovim}/bin/nvim "$@"
        '';

        # Atomic Neovim derivation: contains the config files and the wrapper
        myNvim = pkgs.stdenv.mkDerivation {
          pname = "nvim-flake";
          version = "1.0.0";
          # Point src to the current directory ('.') to capture the 'nvim' folder
          src = pkgs.lib.cleanSource ./.;

          # Only dependency needed is the wrapper script
          buildInputs = [ nvimWrapper ];

          installPhase = ''
            # Create the necessary directories
            mkdir -p $out/bin $out${nvimConfigPath}

            # Copy the nvim config directory from the source subdirectory
            cp -r $src/nvim/* $out${nvimConfigPath}/ 

            # Copy the wrapper script into $out/bin
            cp ${nvimWrapper}/bin/nvim $out/bin/
          '';
        };
      in
      {
        # System-wide package (nix profile install) and app (nix run)
        packages.default = myNvim;
        apps.nvim = {
          type = "app";
          program = "${myNvim}/bin/nvim";
        };
        lib.nvimRuntimeDeps = nvimRuntimeDeps;

        # devShell for project-local development
        devShells.default = pkgs.mkShell {
          packages = [ myNvim ] ++ nvimRuntimeDeps;

          shellHook = ''
            export PATH="${myNvim}/bin:$PATH"
            echo "Neovim dev environment ready. Run 'nvim' to start."
          '';
        };
      }
    );
}
