{
  description = "NixOS configuration with stable nixpkgs + fresh-editor from unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
  let
    system = "x86_64-linux";

    # Unstable package set (only used as a source for selected packages)
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    # Stable package set + overlay that swaps in ONLY fresh-editor from unstable
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };

      overlays = [
        (final: prev: {
          fresh-editor = pkgsUnstable.fresh-editor;
        })
      ];
    };
  in
  {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ];
        pkgs = pkgs;
      };
    };
  };
}
