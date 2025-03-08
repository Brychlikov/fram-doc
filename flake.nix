{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    mdbook-treesitter-src = {
      url = "git+file:///home/brych/repos/mdbook-treesitter/";
      flake = false;
    };
    # mdbook-tree-sitter-src = {
    #   type = "github";
    #   owner = "Corpauration";
    #   repo = "mdbook-treesitter";
    #   flake = false;
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      systems,
      mdbook-treesitter-src,
    }:
    flake-utils.lib.eachSystem (import systems) (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        mdbook-treesitter = with pkgs; pkgs.rustPlatform.buildRustPackage rec {
          pname = "mdbook-treesitter";
          version = "1.0.0";
          src = mdbook-treesitter-src;
          # cargoHash = "";
          buildFeatures = [ "tree-sitter-fram" ];
          cargoLock.lockFile = "${mdbook-treesitter-src}/Cargo.lock";
          cargoLock.allowBuiltinFetchGit = true;
          # cargoLock.outputHashes = {
          #   "tree-sitter-fram-0.1.0" = "";
          # };


          meta = with stdenv.lib; {};

        };
      in
      {
        packages = flake-utils.lib.flattenTree { inherit (pkgs) hello; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mdbook-treesitter
            mdbook-katex
            mdbook
          ];
        };
      }
    );
}
