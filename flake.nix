{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    mdbook-treesitter-src = {
      url = "github:Brychlikov/mdbook-treesitter";
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
        mdbook-treesitter = with pkgs; pkgs.rustPlatform.buildRustPackage {
          pname = "mdbook-treesitter";
          version = "1.0.0";
          src = mdbook-treesitter-src;
          # cargoHash = "";
          buildFeatures = [ "tree-sitter-fram" ];
          cargoLock.lockFile = "${mdbook-treesitter-src}/Cargo.lock";
          cargoLock.allowBuiltinFetchGit = true;
          meta = with stdenv.lib; {};
        };
        deps = with pkgs; [
            mdbook-treesitter
            mdbook-katex
            mdbook
        ];
      in

      {
        packages = flake-utils.lib.flattenTree { 
          default = pkgs.stdenv.mkDerivation {
            pname = "fram-doc";
            version = "0.1.0";
            buildInputs = deps;
            src = ./.;
            buildPhase = ''
              mdbook build -d $out
            '';
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = deps;
        };
      }
    );
}
