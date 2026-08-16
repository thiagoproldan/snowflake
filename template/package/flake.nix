{
  description = "Description for the project";

  inputs = {
    snowflake.url = "github:thiagoproldan/snowflake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ snowflake, ... }:
    snowflake.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, ... }: {
        packages.default = config.packages.hello;

        packages.hello = pkgs.callPackage ./hello/package.nix { };

        checks.hello = pkgs.callPackage ./hello/test.nix {
          hello = config.packages.hello;
        };
      };
    };
}
