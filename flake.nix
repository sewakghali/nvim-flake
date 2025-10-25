{
  description = "Portable Neovim flake with project-local override support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Optional: use a specific neovim overlay for bleeding edge or specific version
    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
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
        # pkgs = import nixpkgs {
        #   inherit system;
        #   overlays = [ self.inputs.neovim-nightly.overlay ];
        # }; # Use this if you add the neovim-nightly input

        # 1. Define the base packages needed for the Neovim runtime
        nvimRuntimeDeps = with pkgs; [
          neovim
          ripgrep
          fd
          git
          stylua
          lua-language-server # Base LSP
        ];

        # 2. Define the path to the installed Neovim config
        nvimConfigPath = "/share/nvim";

        # 3. Create the wrapper script that handles the devcontainer-like logic
        nvimWrapper = pkgs.writeScriptBin "nvim" ''
          #!${pkgs.runtimeShell}
          # This is the path to the base Neovim config installed by the flake
          BASE_CONFIG_DIR="$(${pkgs.coreutils}/bin/dirname "$(readlink -f "$0")")/.."
          BASE_CONFIG="$BASE_CONFIG_DIR${nvimConfigPath}"

          # Check for a project-local config in the current working directory
          if [ -d "./nvim" ]; then
            # Project-local override: set XDG_CONFIG_HOME to $PWD to pick up ./nvim/init.lua
            export XDG_CONFIG_HOME="$(${pkgs.coreutils}/bin/pwd)"
            echo "💡 Using project-local Neovim config: $XDG_CONFIG_HOME/nvim" >&2
          else
            # Fallback to the atomic flake config
            export XDG_CONFIG_HOME="$BASE_CONFIG_DIR"
            echo "⚙️ Using atomic flake Neovim config: $BASE_CONFIG" >&2
          fi

          # Set the PATH for all tools in the derivation
          export PATH="${pkgs.lib.makeBinPath nvimRuntimeDeps}:$PATH"

          # Execute Neovim
          exec ${pkgs.neovim}/bin/nvim "$@"
        '';

        # 4. Atomic Neovim derivation: contains the config files and the wrapper
        myNvim = pkgs.stdenv.mkDerivation {
          pname = "nvim-flake";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./nvim;

          # Only dependency needed is the wrapper script
          buildInputs = [ nvimWrapper ];

          installPhase = ''
            # Create the necessary directories
            mkdir -p $out/bin $out${nvimConfigPath}

            # Copy the entire nvim config directory to $out/share/nvim
            cp -r $src/* $out${nvimConfigPath}/

            # Copy the wrapper script into $out/bin
            cp ${nvimWrapper}/bin/nvim $out/bin/
          '';
        };

      in
      {
        # 5. System-wide package (nix profile install) and app (nix run)
        packages.default = myNvim;
        apps.nvim = {
          type = "app";
          program = "${myNvim}/bin/nvim";
        };

        lib.nvimRuntimeDeps = nvimRuntimeDeps;
      
        # 6. devShell for project-local development
        devShells.default = pkgs.mkShell {
          # Use the 'myNvim' derivation itself to pull in its bin/nvim (the wrapper)
          # and the runtime dependencies.
          packages = [ myNvim ] ++ nvimRuntimeDeps;
          
          shellHook = ''
            # The logic is now inside the wrapper script, but we can set up the shell
            # PATH to use the wrapped nvim executable provided by the 'myNvim' package.
            export PATH="${myNvim}/bin:$PATH"

            # Inform the user
            echo "Neovim dev environment ready. Run 'nvim' to start."
          '';
        };
      }
    );
}
