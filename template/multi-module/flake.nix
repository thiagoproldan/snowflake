{
  description = "Description for the project";

  inputs = {
    snowflake.url = "github:thiagoproldan/snowflake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ snowflake, ... }:
    snowflake.lib.mkFlake { inherit inputs; } {
      imports = [
        ./hello/flake-module.nix
      ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, self', inputs', ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.figlet = inputs'.nixpkgs.legacyPackages.figlet;
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
