{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      systems,
    }:
    flake-utils.lib.eachSystem (import systems) (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        mdbook-treesitter = with pkgs; pkgs.rustPlatform.buildRustPackage rec {
          pname = "mdbook-treesitter";
          version = "1.0.0";
          src = fetchFromGitHub {
            owner = "Corpauration";
            repo = pname;
            rev = "b527e4aa69bf6ee2bbf509ecfc4c14aa889be1b8";
            sha256 = "sha256-j581kaR4IjvpcxxFPlzTx97TNBsfVgyY+76h+OZcLBE=";
          };

          cargoHash = "sha256-X8NEuy/ebMfDHP2QjyB+2sPuffXZOEh+zQsB8RGBYZM=";

          meta = with stdenv.lib; {};

        };
      in
      {
        packages = flake-utils.lib.flattenTree { inherit (pkgs) hello; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mdbook-treesitter
            mdbook
          ];
        };
      }
    );
}
