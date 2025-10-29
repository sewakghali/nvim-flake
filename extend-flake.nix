{
  description = "Extended Neovim flake with Deno and PostgreSQL LSP support";

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

        myNvim = base-nvim.packages.${system}.default;

        # Get the clean list of base runtime dependencies (ripgrep, fd, etc.)
        baseDeps = base-nvim.lib.${system}.nvimRuntimeDeps;

        # Variables for Connection Setup
        dbName = "lsp_dev_db";
        dbUser = "lsp_user";
        dbPass = "super_secret_password";
        dbPort = "5432";
        dbHost = "localhost";

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = baseDeps ++ [
            pkgs.neovim
            pkgs.deno
            pkgs.postgresql_16
            pkgs.postgres-lsp
          ];

          # --- Environment Variables
          PG_HOST = dbHost;
          PG_PORT = dbPort;
          PG_USER = dbUser;
          PG_PASSWORD = dbPass;
          PG_DB = dbName;

          # Directory for the temporary database files (relative to project root)
          POSTGRES_TEMP_DIR = "./.postgres_data";

          shellHook = ''
                        # --- NEOVIM CONFIG SETUP ---
                        # Set the XDG_CONFIG_HOME to point directly to the base config
                        export XDG_CONFIG_HOME="${myNvim}/share"

                        # --- POSTGRES SERVER SETUP ---
                        echo "Initializing temporary PostgreSQL server..."

                        if [ ! -d "$POSTGRES_TEMP_DIR/data" ]; then
                          mkdir -p "$POSTGRES_TEMP_DIR"
                          ${pkgs.postgresql_16}/bin/initdb -D "$POSTGRES_TEMP_DIR/data" --auth=trust
                          
                          # Start server temporarily for initial user/db creation
                          ${pkgs.postgresql_16}/bin/pg_ctl -D "$POSTGRES_TEMP_DIR/data" -o "-p ${dbPort}" -l "$POSTGRES_TEMP_DIR/log" start
                          
                          # Create the user and database using the defined credentials
                          ${pkgs.postgresql_16}/bin/psql -p ${dbPort} -d postgres -c "CREATE USER ${dbUser} WITH PASSWORD '${dbPass}';"
                          ${pkgs.postgresql_16}/bin/psql -p ${dbPort} -d postgres -c "CREATE DATABASE ${dbName} OWNER ${dbUser};"
                          
                          # Stop the server after setup
                          ${pkgs.postgresql_16}/bin/pg_ctl -D "$POSTGRES_TEMP_DIR/data" stop -m fast
                          echo "Database initialized with user '${dbUser}' and database '${dbName}'."
                        fi

                        # Start the PostgreSQL server in the background for this session
                        ${pkgs.postgresql_16}/bin/pg_ctl -D "$POSTGRES_TEMP_DIR/data" -o "-p ${dbPort}" -l "$POSTGRES_TEMP_DIR/log" start

                        # Define a cleanup trap to stop the server when the shell exits
                        trap "${pkgs.postgresql_16}/bin/pg_ctl -D '$POSTGRES_TEMP_DIR/data' stop -m fast" EXIT

            # --- POSTGRES CONNECTION TEST (ADD THIS BLOCK) ---
                        # Set PGPASSWORD temporarily to allow psql to connect without a prompt
                        export PGPASSWORD=${dbPass}
                        
                        # Attempt to connect and execute a simple query ('\c' to connect, then '\q' to quit)
                        if ${pkgs.postgresql_16}/bin/psql -h ${dbHost} -p ${dbPort} -U ${dbUser} -d ${dbName} -c '\q' 2>/dev/null; then
                            echo "DB Connection SUCCESSFUL via psql."
                        else
                            echo "DB Connection FAILED! Check logs in $
            vim.lsp.enable("nil")
            /log"
                        fi
                        
                        # Unset PGPASSWORD immediately after test
                        unset PGPASSWORD
                        # --------------------------------------------------

                        echo "Neovim + PostgreSQL Dev Environment Ready (Server running on port ${dbPort})"
                        echo "   - Connection: ${dbUser}@${dbHost}:${dbPort}/${dbName}"
                        echo "   - Run 'nvim' to start Neovim"
          '';
        };
      }
    );
}
