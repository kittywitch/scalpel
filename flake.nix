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
       }) // {

        nixosModules.scalpel = import ./modules/scalpel {inherit self;};
        nixosModule = self.nixosModules.scalpel;

        };
}
