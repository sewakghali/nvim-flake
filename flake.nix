{
  description = "Neovim dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.neovim;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.neovim
            pkgs.deno
            pkgs.lua-language-server
            pkgs.stylua
            pkgs.prettierd
            pkgs.ripgrep
            pkgs.fd
            pkgs.git
          ];

          shellHook = ''
            export XDG_CONFIG_HOME=$PWD
            echo "Neovim dev environment ready"
          '';
        };

        apps.nvim = {
          type = "app";
          program = "${pkgs.neovim}/bin/nvim";
        };
      });
}
