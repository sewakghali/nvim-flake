{
  description = "Extended Neovim flake with Deno support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    base-nvim = {
      url = "github:sewakghali/nvim-flake/main";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      base-nvim,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # 1. Get the custom Neovim package derivation (myNvim)
        myNvim = base-nvim.packages.${system}.default;

        # 2. Get the clean list of base runtime dependencies (ripgrep, fd, etc.)
        baseDeps = base-nvim.lib.${system}.nvimRuntimeDeps;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            baseDeps # All base runtime tools (ripgrep, fd, etc.)
            ++ [
              pkgs.neovim # Use the raw neovim binary
              pkgs.deno
            ];

          shellHook = ''
            # Set the XDG_CONFIG_HOME to point directly to the base config
            # Neovim will look for $XDG_CONFIG_HOME/nvim
            export XDG_CONFIG_HOME="${myNvim}/share" 

            echo "✅ Neovim + Deno dev environment ready"
            echo "   - Run 'nvim' to start Neovim"
          '';
        };
      }
    );
}
