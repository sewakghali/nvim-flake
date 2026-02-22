{
  description = "Portable Neovim flake - Streamlined";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        runtimeDeps = with pkgs; [ ripgrep fd git stylua lua-language-server nil tree-sitter nodejs_24];

        myNvim = pkgs.symlinkJoin {
          name = "nvim-flake";
          paths = [ pkgs.neovim ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
              --set-default XDG_CONFIG_HOME "${./.}" \
              --set-default XDG_DATA_HOME "$HOME/.local/share/nvim-global-data"
          '';
        };
      in
      {
        lib.nvimRuntimeDeps = runtimeDeps;
        packages.default = myNvim;

        devShells.default = pkgs.mkShell {
          packages = runtimeDeps;
          shellHook = ''
            nvim() {
              if [ -d "./nvim" ]; then
                echo "Using project-local config" >&2
                XDG_CONFIG_HOME="$PWD" XDG_DATA_HOME="$HOME/.local/share/nvim-project-data" ${pkgs.neovim}/bin/nvim "$@"
              else
                # Just use the package we already built!
                ${myNvim}/bin/nvim "$@"
              fi
            }
          '';
        };
      }
    );
}
