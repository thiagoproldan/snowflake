{ config, lib, inputs, self, withSystem, snowflake-lib, ... }:

{
  # Ecosystem compat shim. snowflake renamed the module argument that carries the
  # framework lib: `flake-parts-lib` -> `snowflake-lib`. That is a deliberate clean
  # break, so the framework does NOT provide the old name globally. But every
  # third-party flake-parts module still declares `{ flake-parts-lib, ... }` — all
  # three imported below do. Re-providing the old name here, scoped to this
  # partition, is what keeps them working without forking them.
  #
  # This is the recurring cost of the clean break: each third-party flake-parts
  # module pulled in anywhere needs this arg in scope, or a fork.
  _module.args.flake-parts-lib = snowflake-lib;

  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
    inputs.hercules-ci-effects.flakeModule # herculesCI attr
    inputs.nix-unit.modules.flake.default
  ];
  systems = [ "x86_64-linux" "aarch64-darwin" ];

  hercules-ci.flake-update = {
    enable = true;
    autoMergeMethod = "merge";
    when.dayOfMonth = 1;
    flakes = {
      "." = { };
      "dev" = { };
    };
  };

  perSystem = { config, pkgs, ... }: {

    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [
        config.nix-unit.package
        pkgs.nixpkgs-fmt
        pkgs.hci
      ];
      shellHook = ''
        ${config.pre-commit.shellHook}
      '';
    };

    pre-commit = {
      inherit pkgs; # should make this default to the one it can get via follows
      settings = {
        hooks.nixpkgs-fmt.enable = true;
      };
    };

    checks.perSystem-memoize = pkgs.callPackage ./tests/perSystem-memoize.nix {
      snowflake = self;
    };

    nix-unit.tests = import ./tests/nix-unit.nix { snowflake = self; };

    # nix-unit evaluates the flake, which triggers the dev partition via
    # flake-compat, requiring network to fetch dev inputs.
    nix-unit.allowNetwork = true;

  };
  flake = {
    # for repl exploration / debug
    config.config = config;
    options.mySystem = lib.mkOption { default = config.allSystems.${builtins.currentSystem}; };
    config.effects = withSystem "x86_64-linux" ({ pkgs, hci-effects, ... }: {
      tests = {
        template = pkgs.callPackage ./tests/template.nix { inherit hci-effects; };
      };
    });
  };
}
