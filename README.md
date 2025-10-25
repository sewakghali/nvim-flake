-----

# 🌙 nvim-flake: Portable Neovim Configuration

This repository provides a self-contained, reproducible **Neovim** development environment using **Nix Flakes**. It packages the Neovim configuration, plugins (managed by Lazy.nvim), and essential language servers/tools into an atomic derivation, allowing for easy installation and predictable behavior across any Nix-enabled system.

-----

## 🚀 Motive

The primary goals of this project are:

1.  **Reproducibility:** Ensure that running Neovim today is exactly the same as running it a year from now, regardless of changes to system packages or global state.
2.  **Immutability Bypass:** Solve the common Nix challenge of running stateful applications (like Neovim with a plugin manager) where writable files (lock files, cache) are expected alongside read-only configuration files.
3.  **Flexible Usage:** Support both project-local shell development (`nix develop`) and system-wide installation (`nix profile add`) while maintaining environment isolation.
4.  **Local Overrides:** Provide an easy mechanism to override the base configuration for specific projects without modifying the flake itself.

-----

## 💻 Usage

### 1\. Project-Local Development Environment (Recommended)

Use this method when you want to use the Neovim configuration *and* all the associated tools (like `ripgrep`, `fd`, `lua-language-server`, `deno`, etc.) within a specific project directory.

1.  **Add the flake:** In your project's `flake.nix`, simply add `nvim-flake` as an input and reference its `devShells.default` output.
2.  **Enter the shell:**
    ```bash
    nix develop github:sewakghali/nvim-flake/main
    ```
3.  **Start Neovim:**
    ```bash
    nvim
    ```

### 2\. Global Profile Installation

Use this method to install the custom `nvim` binary and configuration wrapper system-wide, making it available in your `$PATH` regardless of your current directory.

```bash
# Install the package to your user profile
nix profile install github:sewakghali/nvim-flake#default

# Run Neovim from any directory
nvim
```

-----

## 🧩 Features and Quirks

The flake uses custom wrapper logic to handle path resolution and environment setup:

### Feature A: Project-Local Config Override

When you enter a directory that contains a sub-directory named **`./nvim`**, the wrapper automatically switches to using the configuration found in that local directory instead of the globally installed flake config.

  * **Behavior:** If `./nvim` exists, `XDG_CONFIG_HOME` is set to the current directory (`$PWD`).
  * **Use Case:** Quick, project-specific overrides for LSP or plugin configurations without touching your stable global configuration.

### Feature B: Writable Global Configuration (The Fix)

When installed globally via `nix profile` (or when the local override fails), the wrapper employs a **copy-on-first-run** mechanism to solve the Nix immutability issue:

1.  **Check/Copy:** On the first run, the immutable config from the Nix store is copied to a writable user location: `~/.config/nvim-global/nvim`.
2.  **Config Path:** The wrapper sets `XDG_CONFIG_HOME` to the parent directory (`~/.config`), ensuring Neovim uses this **writable copy**.
3.  **Data Redirection:** All mutable data (plugins, cache, `lazy-lock.json`) is redirected to a separate, writable path: `~/.local/share/nvim-global-data`.

This guarantees that plugins can be installed and updated without throwing `Permission denied` errors.

-----

## 🛑 Gotchas and Troubleshooting

### 1\. First-Run Plugin Error

  * **Quirk:** The very first time you launch `nvim` after a fresh installation (or after clearing your cache), you will likely encounter an error message on startup related to a missing Lua module or plugin.
  * **Cause:** This happens because the Lua configuration is loaded before the Lazy plugin manager has finished downloading and installing the dependencies into the `nvim-global-data` directory.
  * **Solution:** Simply **exit Neovim and run `nvim` again**. The restart allows Neovim to load the plugins that were downloaded during the first session.
