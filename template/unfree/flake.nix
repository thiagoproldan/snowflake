{
  description = "Description for the project";

  inputs = {
    snowflake.url = "github:thiagoproldan/snowflake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ snowflake, nixpkgs, ... }:
    snowflake.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { pkgs, system, ... }: {
        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        packages.default = pkgs.hello-unfree;
      };
    };
}
