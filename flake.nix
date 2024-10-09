{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    sops-nix.url = github:Mic92/sops-nix;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = {
    self,
    nixpkgs,
    sops-nix,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        mk_scalpel = {
          matchers,
          source,
          destination,
          user ? null,
          group ? null,
          mode ? null,
        }:
          pkgs.callPackage ./packages/scalpel.nix {
            inherit matchers source destination user group mode;
          };

        nixosModules.scalpel = import ./modules/scalpel {inherit self;};
        nixosModule = self.nixosModules.scalpel;

        nixosConfigurations = let
          base_sys = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              sops-nix.nixosModules.sops
              ./example/system.nix
            ];
          };
        in {
          exampleContainer = base_sys.extendModules {
            modules = [
              self.nixosModules.scalpel
              ./example/scalpel.nix
            ];
            specialArgs = {prev = base_sys;};
          };

          exampleContainerManual = base_sys.extendModules {
            modules = [
              ./example/scalpel-manual.nix
            ];
            specialArgs = {
              prev = base_sys;
              inherit (self) mk_scalpel;
            };
          };
        };
      }
    };
}
